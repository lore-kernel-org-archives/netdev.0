From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: jme: remove unused #include <version.h>
Date: Mon, 13 Oct 2008 00:20:34 +0800
Message-ID: <20081012162020.M92682@cooldavid.org>
References: <20081012231101.E7EF.WEIYI.HUANG@gmail.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: netdev@vger.kernel.org
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:47131 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbYJLQVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 12:21:10 -0400
In-Reply-To: <20081012231101.E7EF.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Oct 2008 23:12:54 +0800, Huang Weiyi wrote
> The file(s) below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
>   drivers/net/jme.c
> 
> This patch removes the said #include <version.h>.
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
Got it! Thank you. ^^ 

Guo-Fu Tseng

