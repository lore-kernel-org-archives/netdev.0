From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: au1000_eth: remove unused global variable.
Date: Sat, 11 Dec 2010 12:01:58 -0800 (PST)
Message-ID: <20101211.120158.39187953.davem@davemloft.net>
References: <1292097222-11319-1-git-send-email-manuel.lauss@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florian@openwrt.org
To: manuel.lauss@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60999
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345Ab0LKUBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 15:01:30 -0500
In-Reply-To: <1292097222-11319-1-git-send-email-manuel.lauss@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@googlemail.com>
Date: Sat, 11 Dec 2010 20:53:42 +0100

> The driver global au_macs[] is unused in the entire kernel tree,
> so remove it.
> 
> Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>

Applied, thanks.
