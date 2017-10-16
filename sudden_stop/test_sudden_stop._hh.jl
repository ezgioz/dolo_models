#path = Pkg.dir("Dolo")
import Dolo
using AxisArrays
N= 1 # number  of simulations
T=100 # periods of simulation
hor= linspace(1, T, T)

import PyPlot
plt = PyPlot;

path = pwd()
#fn = ("https://raw.githubusercontent.com/ezgioz/dolo_models/ezgioz/sudden-stop-models/sudden_stop/sudden_stop_cd.yaml");
fn = joinpath(path,"sudden_stop","sudden_stop_cd_hh.yaml")
model = Dolo.yaml_import(fn)

# Change the domain if needed
#Dolo.set_calibration!(model, :minle, -0.54)
#Dolo.set_calibration!(model, :minlw, -0.54)

sol = Dolo.time_iteration(model, verbose=true)

#Solve with initial dr after solving for some part of the domain
sol = Dolo.time_iteration(model, sol.dr, verbose=true)

# Simulating a decision rule for MC-discretization case
dr = sol.dr
s0 = model.calibration[:states]
#index = findfirst(model.symbols[:states],:lw)

# Define the bounds for your states variable
#bounds = [dr.grid_endo.min[index], dr.grid_endo.max[index]]

df_mc1 = Dolo.tabulate(model, dr, :lw, s0, 1)
df_mc2 = Dolo.tabulate(model, dr, :lw, s0, 2)

df_mc1e = Dolo.tabulate(model, dr, :le, s0, 1)
df_mc2e = Dolo.tabulate(model, dr, :le, s0, 2)


hor= linspace(1, T, T)

fig = plt.figure("Competitive Equilibrium")

plt.plot(df_mc1[:lw], df_mc1[Axis{:V}(:bw)], color="blue", linestyle="dashed", alpha = .5, label="Low state of y workers")
plt.plot(df_mc2[:lw], df_mc2[Axis{:V}(:bw)], color="blue",  alpha = .5, label="High state of y workers")
plt.text(model.calibration.flat[:maxlw], maximum(df_mc2[Axis{:V}(:bw)].data), "bw'")

plt.plot(df_mc1e[:le], df_mc1e[Axis{:V}(:be)], color="red", linestyle="dashed", alpha = .5, label="Low state of y top earners")
plt.plot(df_mc2e[:le], df_mc2e[Axis{:V}(:be)], color="red",  alpha = .5, label="High state of y top earners")
plt.text(model.calibration.flat[:maxle], maximum(df_mc2e[Axis{:V}(:be)].data), "be'")

# This part will be working when definitions can be obtained by tabulate

#plt.plot(df_mc1[:lw], df_mc1[Axis{:V}(:cTw)], color="blue", linestyle="dashed", alpha = .5,)
#plt.plot(df_mc2[:lw], df_mc2[Axis{:V}(:cTw)], color="blue",  alpha = .5)
#plt.text(model.calibration.flat[:maxl], maximum(df_mc2[Axis{:V}(:cTw)].data), "cTw")
#
#plt.plot(df_mc1e[:le], df_mc1e[Axis{:V}(:cTe)], color="red", linestyle="dashed", alpha = .5,)
#plt.plot(df_mc2e[:le], df_mc2e[Axis{:V}(:cTe)], color="red",  alpha = .5)
#plt.text(model.calibration.flat[:maxl], maximum(df_mc2e[Axis{:V}(:cTe)].data), "cTe")

#plt.plot(df_mc1[:lw], df_mc1[Axis{:V}(:p)], color="blue", linestyle="dashed", alpha = .5,)
#plt.plot(df_mc2[:lw], df_mc2[Axis{:V}(:p)], color="blue", alpha = .5)
#plt.text(model.calibration.flat[:maxl], maximum(df_mc2[Axis{:V}(:p)].data) - 0.2, "p")


#plt.plot(df_mc1e[:le], df_mc1e[Axis{:V}(:p)], color="red", linestyle="dashed", alpha = .5,)
#plt.plot(df_mc2e[:le], df_mc2e[Axis{:V}(:p)], color="blue", alpha = .5)
#plt.text(model.calibration.flat[:maxl], maximum(df_mc2[Axis{:V}(:p)].data) - 0.2, "p")

# Approximate point where 45 degree line intersects the decision rule for steady state
plt.axvline(df_mc1[:lw].data[findmin(abs(df_mc2[Axis{:V}(:bw)].data - df_mc1[:lw].data))[2]],color="black", linestyle="dashed", alpha = .2)
plt.axvline(df_mc1e[:le].data[findmin(abs(df_mc2[Axis{:V}(:be)].data - df_mc1[:le].data))[2]],color="red", linestyle="dashed", alpha = .2)


#45 degree line
plt.plot(df_mc2[:lw], df_mc2[:lw], color="black", linestyle="dashed", alpha = .2)

plt.xlabel("Bond holdings");
plt.legend()
plt.ylabel("The desicion rule (Next period holdings)");
plt.title("Decision rule for Sudden Stop - Exchange rate model");
#
