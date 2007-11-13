From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/ipvs/: remove unused exports
Date: Mon, 12 Nov 2007 21:25:11 -0800 (PST)
Message-ID: <20071112.212511.109029415.davem@davemloft.net>
References: <20071111064840.GJ21669@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rumen@voicecho.com, wensong@linux-vs.org, horms@verge.net.au,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760803AbXKMFZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:25:12 -0500
In-Reply-To: <20071111064840.GJ21669@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 11 Nov 2007 07:48:40 +0100

> This patch removes the following unused EXPORT_SYMBOL's:
> - ip_vs_try_bind_dest
> - ip_vs_find_dest
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
