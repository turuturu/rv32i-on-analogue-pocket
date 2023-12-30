#
# Copyright (c) 2023-present Didier Malenfant
#
# This file is part of openFPGA-Tutorials.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

import pfDevTools

# -- We need pf-dev-tools version 1.x.x but at least this version.
pfDevTools.requires("1.1.0")

#env = pfDevTools.SConsEnvironment(
    #PF_CORE_TEMPLATE_REPO_URL="codeberg.org/DidierMalenfant/pfCoreTemplate",
    #PF_CORE_TEMPLATE_REPO_TAG="v0.0.6_for_openFPGATutorials",
#)
#env = pfDevTools.SConsEnvironment(
    #PF_CORE_TEMPLATE_REPO_URL="codeberg.org/DidierMalenfant/pfCoreTemplate",
    #PF_CORE_TEMPLATE_REPO_TAG="v0.0.6_for_openFPGATutorials",
#)
#env = pfDevTools.SConsEnvironment(
    #PF_CORE_TEMPLATE_REPO_URL="github.com/open-fpga/core-template",
    #PF_CORE_TEMPLATE_REPO_TAG="v1.3.0",
    ###PF_CORE_QSF_FILE="ap_core.qsf",
    ##PF_DEBUG_ON=True
#)
env = pfDevTools.SConsEnvironment(
    PF_CORE_TEMPLATE_REPO_URL="github.com/turuturu/core-template",
    PF_CORE_TEMPLATE_REPO_TAG="v1.3.0-t",
)

env.OpenFPGACore("src/config.toml")
