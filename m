From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: get rid of the 2nd parameter to sh_eth_dev_init()
Date: Mon, 25 Apr 2016 10:30:21 +1000
Message-ID: <20160425003021.GC30009@verge.net.au>
References: <1615196.r6Bb3HFTJZ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33313 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbcDYAaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 20:30:24 -0400
Content-Disposition: inline
In-Reply-To: <1615196.r6Bb3HFTJZ@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2016 at 07:11:07PM +0300, Sergei Shtylyov wrote:
> sh_eth_dev_init()  is now always called with  'true' as the  2nd argument,
> so that there's no more sense in having 2 parameters to this function...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
