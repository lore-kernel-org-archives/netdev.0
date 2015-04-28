From: Anders Larsen <al@alarsen.net>
Subject: Stable request 9374e7d2 "rtlwifi: rtl8192cu: Add new device ID"
Date: Tue, 28 Apr 2015 15:56:04 +0200
Message-ID: <1430229364.6036.1@alarsen-lx>
References: <201504271819.57895.marex@denx.de>
Reply-To: Anders Larsen <al@alarsen.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: Marek Vasut <marex@denx.de>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jesper.alarsen.net ([144.76.18.233]:41471 "EHLO
	mail.alarsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965465AbbD1N4I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 09:56:08 -0400
In-Reply-To: <201504271819.57895.marex@denx.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

commit 9374e7d2fdcad3c36dafc8d3effd554bc702c4b6
Author: Marek Vasut <marex@denx.de>
Date:   2015-03-26 02:16:06 +0100

     rtlwifi: rtl8192cu: Add new device ID

     Add new ID for ASUS N10 WiFi dongle.

in Linus' tree has been tested on 3.16.7 and 3.10.5x
and applies cleanly all the way back to 3.2.68

Please consider this patch for the stable trees.

Thanks,
Anders
