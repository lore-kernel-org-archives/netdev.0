From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek driver issue in Ubuntu 12.01
Date: Sun, 7 Jul 2013 23:44:35 +0200
Message-ID: <20130707214435.GA25259@electric-eye.fr.zoreil.com>
References: <51D98047.6010000@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, curtiswest@rogers.blackberry.net
To: Curtis West <curtiswest@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35148 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab3GGVok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 17:44:40 -0400
Content-Disposition: inline
In-Reply-To: <51D98047.6010000@shaw.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Curtis West <curtiswest@shaw.ca> :
[...]
> I have the Realtek RTL8723AE wireless Lan 802.11(n) card according
> to the specs posted by Toshiba for this model.  The drivers that are
> installed according to the software I have used is the Realtek
> RTL-8169 Gigabit Ethernet Driver.
> 
> What do I need to do to get this wifi issue solved?

The r8169 driver supports wired ethernet chipsets only. 

You need the rtlwifi module and you may check the linux-wireless mailing
list archive.

-- 
Ueimor
