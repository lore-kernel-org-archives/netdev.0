From: patnel972-linux@yahoo.fr
Subject: Bonding : Monitoring of 4965 wireless card
Date: Wed, 9 Jan 2008 09:00:05 +0000 (GMT)
Message-ID: <802012.38504.qm@web25708.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25708.mail.ukl.yahoo.com ([217.12.10.180]:35901 "HELO
	web25708.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752087AbYAIJAK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 04:00:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I want to make a bond with my wireless card. The ipw driver create two
 interfaces (wlan0 and wmaster0). When i switch the rf_kill button,
 ifplug detect wlan0 unplugged but not wmaster0. If i down wlan0 (while
 rf_kil ), bonding detect the inactivity when i up the interface.

Have you some idea where is the problem? the driver or the miimon of
 the module?

my module parameters mode=1 miimon=100 primary eth0

Thanks



      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail http://mail.yahoo.fr
