From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] VIOC: New Network Device Driver
Date: Mon, 11 Sep 2006 00:21:09 +0200
Message-ID: <20060910222109.GA22386@electric-eye.fr.zoreil.com>
References: <000501c6d85c$08a352f0$8301a8c0@calvados> <200609102339.25621.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Misha Tomushev <misha@fabric7.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:15325 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932113AbWIJWYv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 18:24:51 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200609102339.25621.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> :
[...]
> A few comments on coding style:

Add:
- use netdev_priv()
- use DMA_{32/64}_BIT_MASK in place of private #define
- turn some define into enum ?

-- 
Ueimor
