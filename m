From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 3/3] sh_eth: get rid of bb_{set|clr|read}()
Date: Tue, 8 Dec 2015 09:42:37 +0900
Message-ID: <20151208004236.GJ10799@verge.net.au>
References: <1582774.FcjyuztLtc@wasted.cogentembedded.com>
 <2620242.OINoAeziLK@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55225 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774AbbLHAmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 19:42:38 -0500
Content-Disposition: inline
In-Reply-To: <2620242.OINoAeziLK@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 12:41:43AM +0300, Sergei Shtylyov wrote:
> After the MDIO bitbang code consolidation, there's no need anymore for
> bb_{set|clr}() as well as bb_read() -- just expand them inline, thus
> saving more LoCs...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>
