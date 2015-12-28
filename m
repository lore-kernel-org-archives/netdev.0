From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] sh_eth: get rid of {cpu|edmac}_to_{edmac|cpu}()
Date: Mon, 28 Dec 2015 16:32:29 +1100
Message-ID: <20151228053229.GH1066@verge.net.au>
References: <27915743.MLN0FvErP3@wasted.cogentembedded.com>
 <7645144.Pie2WFS3t2@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60403 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbbL1Fcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 00:32:31 -0500
Content-Disposition: inline
In-Reply-To: <7645144.Pie2WFS3t2@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2015 at 02:10:47AM +0300, Sergei Shtylyov wrote:
> Now that {cpu|edmac}_to_{edmac|cpu}() functions boiled down to the mere
> {cpu|le32}_to_{le32|cpu}() calls, there's no need for these functions
> anymore, so just get rid of them.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>
