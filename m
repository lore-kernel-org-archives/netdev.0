From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 0/6] drivers: isdn: act2000: fix a variety of checkpatch errors.
Date: Sat,  7 Feb 2015 18:06:31 +0100
Message-ID: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset tackles a variety of checkpatch errors. Some apparent errors were ommitted because fixing them would in no way contribute to readability.

Signed-off-by: Bas Peters <baspeters93@gmail.com>

Bas Peters (6):
  drivers: isdn: act2000: act2000_isa.c: Fix checkpatch errors
  drivers: isdn: act2000: capi.c: fix checkpatch errors
  drivers: isdn: act2000: remove assignments of variables in if
    conditions
  drivers: isdn: act2000: module.c: remove NULL-initialization of static
        variable.
  drivers: isdn: act2000: module.c: remove parenthesres around return   
     values.
  drivers: isdn: act2000: fix wrongly positioned brace.

 drivers/isdn/act2000/act2000_isa.c | 11 +++++----
 drivers/isdn/act2000/capi.c        |  9 +++++---
 drivers/isdn/act2000/module.c      | 47 +++++++++++++++++++++++---------------
 3 files changed, 41 insertions(+), 26 deletions(-)

-- 
2.1.0
