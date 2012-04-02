From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 21/51] ipvs: Stop using NLA_PUT*().
Date: Mon, 2 Apr 2012 14:01:49 +0900
Message-ID: <20120402050142.GA20454@verge.net.au>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
 <1333335521-1348-22-git-send-email-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34961 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab2DBFBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 01:01:55 -0400
Content-Disposition: inline
In-Reply-To: <1333335521-1348-22-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 01, 2012 at 10:58:11PM -0400, David S. Miller wrote:
> From: "David S. Miller" <davem@davemloft.net>
> 
> These macros contain a hidden goto, and are thus extremely error
> prone and make code hard to audit.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Hi Dave,

do you want me to take this patch or do you plan to take it directly?

In any case

Acked-by: Simon Horman <horms@verge.net.au>
