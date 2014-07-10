From: varkabhadram@gmail.com
Subject: [PATCH net 0/7] cleanup for AR7 CPMAC Ethernet controller driver
Date: Thu, 10 Jul 2014 10:17:53 +0530
Message-ID: <1404967680-13206-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61104 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaGJEtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 00:49:21 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so10383563pad.35
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 21:49:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This series fix the cleanup for AR7 CPMAC Ethernet controller driver

Varka Bhadram (7):
  net: cpmac: remove space in macro defination
  net: cpmac: fix comments
  net: cpmac: dynamic debug fixes
  net: cpmac: fix cpmac driver structure
  net: cpmac: fix missing a blank line after declarations
  net: cpmac: fix proper spacing before return statement
  net: cpamc: fix in releasing resources

 drivers/net/ethernet/ti/cpmac.c |  287 ++++++++++++++++++++-------------------
 1 file changed, 148 insertions(+), 139 deletions(-)

-- 
1.7.9.5
