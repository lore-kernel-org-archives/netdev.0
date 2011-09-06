From: Tanmay Upadhyay <tanmay.upadhyay@einfochips.com>
Subject: net: pxa168: Fix build errors by including interrupt.h
Date: Tue,  6 Sep 2011 11:02:03 +0530
Message-ID: <1315287124-13972-1-git-send-email-tanmay.upadhyay@einfochips.com>
Cc: netdev@vger.kernel.org
To: ssanap@marvell.com, zgao6@marvell.com, prakity@marvell.com,
	markb@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ahm.einfochips.com ([203.76.128.206]:8157 "EHLO
	ahm.einfochips.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab1IFFli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 01:41:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I saw a recent patch that moves pxa168_eth.c to ethernet/marvell.
I still hope my patch is useful as I didn't any patch fixing these
build errors. Please ignore if it's already fixed somewhere.

Thanks,
Tanmay
