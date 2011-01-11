From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ah: update maximum truncated ICV length
Date: Tue, 11 Jan 2011 14:05:03 -0800 (PST)
Message-ID: <20110111.140503.215549717.davem@davemloft.net>
References: <4D2C9C1B.1030907@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43198
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932144Ab1AKWEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 17:04:31 -0500
In-Reply-To: <4D2C9C1B.1030907@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 11 Jan 2011 19:06:19 +0100

>>From 2ca463cf672f000d37a0aaa5e3d3738b50661926 Mon Sep 17 00:00:00 2001
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu, 23 Dec 2010 09:52:21 -0500
> Subject: [PATCH] ah: update maximum truncated ICV length
> 
> For SHA256, RFC4868 requires to truncate ICV length to 128 bits,
> hence MAX_AH_AUTH_LEN should be updated to 16.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
