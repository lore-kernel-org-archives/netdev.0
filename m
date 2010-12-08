From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: fix freeing pg_vec twice on error path
Date: Wed, 08 Dec 2010 10:44:17 -0800 (PST)
Message-ID: <20101208.104417.179940357.davem@davemloft.net>
References: <1291734318-17989-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jpirko@redhat.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33168
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753896Ab0LHSnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:43:51 -0500
In-Reply-To: <1291734318-17989-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue,  7 Dec 2010 23:05:18 +0800

> It is introduced in:
>         commit 0e3125c755445664f00ad036e4fc2cd32fd52877
>         Author: Neil Horman <nhorman@tuxdriver.com>
>         Date:   Tue Nov 16 10:26:47 2010 -0800
>     
>         packet: Enhance AF_PACKET implementation to not require high order contiguous memory allocation (v4)
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
