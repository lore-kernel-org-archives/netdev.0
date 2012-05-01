From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Tue, 1 May 2012 14:51:54 +0200
Message-ID: <20120501125154.GO3157@wantstofly.org>
References: <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
 <20120427101732.GX3157@wantstofly.org>
 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
 <20120427185809.GZ3157@wantstofly.org>
 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
 <CAJfuBxw7YFAC9CLAGNmg3nM_g2xH2vuiz07D-3xOcyn2XuP5vA@mail.gmail.com>
 <CA+icZUVT6kvqj47x26FU2qjbMHc=jr9_Lso=zduf_cmcSrv=UQ@mail.gmail.com>
 <CAJfuBxwz2PmNY37VB7Wx+GdQcOcS6Y96EM_JNtvs-dyv-imL6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sedat.dilek@gmail.com, "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	lautriv <admin@coldplug.net>
To: Jim Cromie <jim.cromie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61351 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab2EAMv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 08:51:56 -0400
Content-Disposition: inline
In-Reply-To: <CAJfuBxwz2PmNY37VB7Wx+GdQcOcS6Y96EM_JNtvs-dyv-imL6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 05:11:06PM -0600, Jim Cromie wrote:

> That said, bitrate is quite low, I havent looked at why.
> 
> jimc@chumly:~/projects/lx/wifi/mwl8k-8361p-logs$ grep -i MBit *
> iw-dev-wlan0-link:	tx bitrate: 11.0 MBit/s
> iw-dev-wlan1-link:	tx bitrate: 1.0 MBit/s
> iw-dev-wlan1-station-dump:	tx bitrate:	1.0 MBit/s
> iw-dev-wlan1-station-get-00:14:d1:e8:65:0a:	tx bitrate:	1.0 MBit/s

You can ignore those values, they don't reflect the actual
transmittion rate in use.
