From: Robert Olsson <robert@herjulf.net>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Mon, 19 Nov 2012 15:27:09 +0800
Message-ID: <20649.57165.292525.276405@gargle.gargle.HOWL>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	<1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	<CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
	<1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
	<CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
	<CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
	<50A570D7.3080409@gmail.com>
	<1353022205.4867.76.camel@deadeye.wl.decadent.org.uk>
	<CAPN4dA_ymo-Bx+GM+JLLKGHghq+qBYxR0zO7K6H6Nn0pqZsJRg@mail.gmail.com>
	<1353094719.2743.21.camel@bwh-desktop.uk.solarflarecom.com>
	<CAPN4dA9f3y1mDPubqd9s+v5supj3hNvZaWym0_y3EMZd7L6MyQ@mail.gmail.com>
Reply-To: robert@herjulf.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: footplus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:39011 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab2KSHdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 02:33:38 -0500
In-Reply-To: <CAPN4dA9f3y1mDPubqd9s+v5supj3hNvZaWym0_y3EMZd7L6MyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
FYI. DOM use in Serengeti Tanzania (Bunda-Nata 60km) on solar driven low-power 
linux atom router @ 20Watt w. igb driver using the older DOM pathes. Very useful 
stuff. Yes get included in the kernel.

NATA:/# ethtool -D eth1
Ext-Calbr: Avr RX-Power: Alarm & Warn: RX_LOS: 	Wavelength: 1550 nm
Alarms, warnings in beginning of line, Ie. AH = Alarm High, WL == Warn Low etc
	Temp:  76.2 C			Thresh: Lo: -50.0/-48.0  Hi:  95.0/110.0 C
	Vcc:  3.27 V			Thresh: Lo:   2.9/3.0    Hi:   3.5/3.6   V
	Tx-Bias:  27.9 mA		Thresh: Lo:   3.0/5.0    Hi:  90.0/100.0 mA
	TX-pwr:   3.8 dBm ( 2.39 mW)	Thresh: Lo:  -5.0/-4.0   Hi:   5.0/6.0   dBm
	RX-pwr: -17.3 dBm ( 0.02 mW) 	Thresh: Lo: -40.0/-37.0  Hi:  -5.0/-3.0  dBm

http://herjulf.se/robert/tanzania-2012/Nata-installation-2.jpg

						--ro
