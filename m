From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/3] sh_eth: remove mask fields from 'struct bb_info'
Date: Tue, 8 Dec 2015 09:42:21 +0900
Message-ID: <20151208004221.GH10799@verge.net.au>
References: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
 <8193175.UjRYeBy7vc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55146 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbbLHAmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 19:42:22 -0500
Content-Disposition: inline
In-Reply-To: <8193175.UjRYeBy7vc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 12:40:19AM +0300, Sergei Shtylyov wrote:
> The MDIO control bits are always mapped to the same bits of the same register
> (PIR), so there's no need to store their masks in the 'struct bb_info'...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>
