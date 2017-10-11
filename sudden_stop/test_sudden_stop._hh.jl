#path = Pkg.dir("Dolo")
import Dolo
using AxisArrays

path = pwd()
#fn = ("https://raw.githubusercontent.com/ezgioz/dolo_models/ezgioz/sudden-stop-models/sudden_stop/sudden_stop_cd.yaml");
fn = joinpath(path,"sudden_stop","sudden_stop_cd_hh.yaml")


model = Dolo.yaml_import(fn);

#The process hasa transition probability matrix
print(model.exogenous.transitions)
# and values for two states: bad state & good state
print(model.exogenous.values)

N= 1 # number  of simulations
T=100 # periods of simulation
hor= linspace(1, T, T)

import PyPlot
plt = PyPlot;



fig = plt.figure("Sudden Stop Markov Chain")

mc = model.exogenous
sim_mc= Dolo.simulate(model.exogenous, N, T, 1)

plt.plot(hor, mc.grid.nodes[sim_mc], color="blue", alpha = .35, label ="MC")
plt.legend()
plt.xlabel("Horizon");
plt.title("Sudden Stop Markov Chain");

Dolo.set_calibration!(model, :minlw, -0.35)
Dolo.set_calibration!(model, :minle, -0.35)

sol = Dolo.time_iteration(model, verbose=true)
Dolo.set_calibration!(model, :minlw, -1.1)
sol = Dolo.time_iteration(model, sol.dr, verbose=true)
Dolo.set_calibration!(model, :minl, -1.15)
sol = Dolo.time_iteration(model, sol.dr, verbose=true)
Dolo.set_calibration!(model, :minl, -1.20)
sol = Dolo.time_iteration(model, sol.dr, verbose=true)


# Simulating a decision rule for MC-discretization case
dr = sol.dr
s0 = model.calibration[:states]
index = findfirst(model.symbols[:states],:lw)

# Define the bounds for your states variable
bounds = [dr.grid_endo.min[index], dr.grid_endo.max[index]]

df_mc1 = Dolo.tabulate(model, dr, :lw, s0, 1)
df_mc2 = Dolo.tabulate(model, dr, :lw, s0, 2)

df_mc1e = Dolo.tabulate(model, dr, :le, s0, 1)
df_mc2e = Dolo.tabulate(model, dr, :le, s0, 2)


hor= linspace(1, T, T)

fig = plt.figure("Competitive Equilibrium")

plt.plot(df_mc1[:lw], df_mc2[Axis{:V}(:bw)], color="blue", alpha = .5, label="High state of y workers")
plt.plot(df_mc2[:lw], df_mc1[Axis{:V}(:bw)], color="blue", linestyle="dashed", alpha = .5, label="Low state of y workers")

plt.plot(df_mc1e[:le], df_mc2[Axis{:V}(:be)], color="red", alpha = .5, label="High state of y entr")
plt.plot(df_mc2e[:le], df_mc1[Axis{:V}(:be)], color="red", linestyle="dashed", alpha = .5, label="Low state of y entr")

plt.plot(df_mc2[:lw], df_mc2[:lw], color="black", linestyle="dashed", alpha = .2)

#plt.ylim((bounds[1],bounds[2]))
#plt.xlim((bounds[1],bounds[2]))

plt.xlabel("Bond holdings");
plt.legend()
plt.ylabel("The desicion rule (Next period holdings)");
plt.title("Decision rule for Sudden Stop - Exchange rate model");
