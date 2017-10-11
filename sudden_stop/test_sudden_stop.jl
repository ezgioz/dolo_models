#path = Pkg.dir("Dolo")
import Dolo
using AxisArrays

path = pwd()
#fn = ("https://raw.githubusercontent.com/ezgioz/dolo_models/ezgioz/sudden-stop-models/sudden_stop/sudden_stop_cd.yaml");
fn = joinpath(path,"sudden_stop","sudden_stop_cd.yaml")


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

Dolo.set_calibration!(model, :minl, -0.9)
sol = Dolo.time_iteration(model, verbose=true)
Dolo.set_calibration!(model, :minl, -1.1)
sol = Dolo.time_iteration(model, sol.dr, verbose=true)
Dolo.set_calibration!(model, :minl, -1.15)
sol = Dolo.time_iteration(model, sol.dr, verbose=true)
Dolo.set_calibration!(model, :minl, -1.20)
sol = Dolo.time_iteration(model, sol.dr, verbose=true)


# Simulating a decision rule for MC-discretization case
dr = sol.dr
s0 = model.calibration[:states]
#index = findfirst(model.symbols[:states],:l)

# Define the bounds for your states variable
#bounds = [dr.grid_endo.min[index], dr.grid_endo.max[index]]

df_mc1 = Dolo.tabulate(model, dr, :l, s0, 1)
df_mc2 = Dolo.tabulate(model, dr, :l, s0, 2)


hor= linspace(1, T, T)

fig = plt.figure("Competitive Equilibrium")

plt.plot(df_mc1[:l], df_mc2[Axis{:V}(:b)], color="blue", alpha = .5, label="High state of y")
plt.plot(df_mc2[:l], df_mc1[Axis{:V}(:b)], color="red", linestyle="dashed", alpha = .5, label="Low state of y")
plt.text(model.calibration.flat[:maxl], maximum(df_mc2[Axis{:V}(:b)].data) - 0.2, "b'")

plt.plot(df_mc1[:l], df_mc2[Axis{:V}(:cT)], color="blue", alpha = .5,)
plt.plot(df_mc2[:l], df_mc1[Axis{:V}(:cT)], color="red", linestyle="dashed", alpha = .5)
plt.text(model.calibration.flat[:maxl], maximum(df_mc2[Axis{:V}(:cT)].data) - 0.2, "cT")

plt.plot(df_mc1[:l], df_mc2[Axis{:V}(:p)], color="blue", alpha = .5,)
plt.plot(df_mc2[:l], df_mc1[Axis{:V}(:p)], color="red", linestyle="dashed", alpha = .5)
plt.text(model.calibration.flat[:maxl], maximum(df_mc2[Axis{:V}(:p)].data) - 0.2, "p")

plt.axvline(df_mc1[:l].data[findmin(abs(df_mc2[Axis{:V}(:b)].data - df_mc1[:l].data))[2]],color="black", linestyle="dashed", alpha = .2)
plt.plot(df_mc2[:l], df_mc2[:l], color="black", linestyle="dashed", alpha = .2)

#plt.ylim((bounds[1],bounds[2]))
#plt.xlim((bounds[1],bounds[2]))

plt.xlabel("Bond holdings at t-1");
plt.legend()
plt.ylabel("The desicion rule");
plt.title("Sudden Stop - Exchange rate model");
