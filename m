From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [BUGZILLA] network wireless bugs
Date: Thu, 4 Oct 2007 09:46:13 -0700
Message-ID: <20071004094613.242f1533@freepuppy.rosehill>
References: <20071004094426.5321af0e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41492 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756179AbXJDQsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 12:48:16 -0400
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l94GmEgF001563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 09:48:15 -0700
In-Reply-To: <20071004094426.5321af0e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

13 bugs found.
ID 	Assignee 	Status 	Resolution 	Version 	Summary
4186 	linville@tuxdriver.com 	ASSI 		2.6.9 	(wireless airo) Aironet 340 PCMCIA does not support WPA
6834 	linville@tuxdriver.com 	ASSI 		2.6.17-rc6 	wpa_supplicant does not work if wifi device is part of a ...
7051 	linville@tuxdriver.com 	ASSI 		2.6.18-rc4 	prism54 does not respect carrier
7682 	Larry.Finger@lwfinger.net 	ASSI 		2.6.19.1 	bcm43xx: iwlist scan: "no scan results" with 2.6.19.1
7752 	kune@deine-taler.de 	ASSI 		2.6.20-rc2-g747... 	drivers/net/wireless/zd1211rw/zd_chip.c:1461 ASSERT r >= ...
7946 	yi.zhu@intel.com 	NEW 		2.6.19.2 	ipw2200 driver + wpa_supplicant (wpa-psk) = fail to send ...
8447 	dsd@gentoo.org 	NEW 		2.6.21.1 686 	zd1211rw does not bring ethX up on some hardware setups
8930 	linville@tuxdriver.com 	ASSI 		2.6.23-rc3 	duplicate forward declaration of void hostap_80211_rx in ...
8934 	drivers_network-wireless@ke... 	REOP 		2.6.22.5 	System freeze when restarting network connection with Bro...
8972 	dsd@gentoo.org 	NEW 		2.6.23-rc4 	zd1211 device is no longer configured
9012 	drivers_network-wireless@ke... 	NEW 		2.6.23-rc6 	RTL8187 - Losing essid
9033 	drivers_network-wireless@ke... 	NEW 		2.6.22.6 	bcm43xx: MAC suspend failed and can't find any network
9072 	drivers_network-wireless@ke... 	NEW 		2.16.20.1 	rmmod zd1211rw causes assertion failure in net/sched/sch_...
