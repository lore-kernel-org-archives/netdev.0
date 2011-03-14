From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH 0/3] bonding: various fixes
Date: Mon, 14 Mar 2011 09:22:03 -0700
Message-ID: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42286 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201Ab1CNQWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:22:24 -0400
Received: by qwk3 with SMTP id 3so1404142qwk.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 09:22:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few collected fixes to bonding.  Patches are against net-next,
but should apply fine to 38-rc.   

Phil


 bond_main.c  |   15 +++++++++++----
 bond_sysfs.c |    5 ++++-
 2 files changed, 15 insertions(+), 5 deletions(-)
