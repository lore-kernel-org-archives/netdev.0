From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH V2 0/7] drivers: isdn: act2000: fix checkpatch errors.
Date: Sat,  7 Feb 2015 20:05:22 +0100
Message-ID: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adresses many checkpatch errors found in the act2000 driver. 

Bas Peters (7):
  drivers: isdn: act2000: act2000_isa.c: Fix checkpatch errors
  drivers: isdn: act2000: capi.c: fix checkpatch errors
  drivers: isdn: act2000: remove assignments of variables in if
    conditions
  drivers: isdn: act2000: module.c: remove NULL-initialization of static
        variable.
  drivers: isdn: act2000: module.c: remove parenthesres around return   
     values.
  drivers: isdn: act2000: fix wrongly positioned brace.
  drivers: isdn: act2000: capi.c: add macro \ and fix brace

 drivers/isdn/act2000/act2000_isa.c | 11 +++++----
 drivers/isdn/act2000/capi.c        | 10 +++++---
 drivers/isdn/act2000/module.c      | 47 +++++++++++++++++++++++---------------
 3 files changed, 42 insertions(+), 26 deletions(-)

-- 
2.1.0
