from dolo import *
import os

dirs = ["RBCS", "LAMP"]
error_list = []

for folder in dirs:

    dir = os.listdir(folder)
    for file in dir:
        if file.endswith("yaml"):
            fname = folder + '/' + file
            message_import = file + " is successfully imported"
            message_perturb  = file + " is successfully solved by perturbation"
            message_time_iteration  = file + " is successfully solved by time iteration"
            err_message_import = file + " can not be imported"
            err_message_perturb = "Can not solve " + file + " by perturbation"
            err_message_time_iteration = "Can not solve " + file + " by time iteration"
            try:
                model = yaml_import(fname)
                #print(message_import)
            except:
                #print(err_message_import)
                error_list.append(err_message_import)
            try:
                dr_pert = perturb(model)
                #print(message_perturb)
            except:
                #print(err_message_perturb)
                error_list.append(err_message_perturb)
            try:
                dr_global = time_iteration(model, verbose=False)
                #print(message_time_iteration)
            except:
                #print(err_message_time_iteration)
                error_list.append(err_message_time_iteration)

# Or print only errors
for err in error_list:
    print(err)
