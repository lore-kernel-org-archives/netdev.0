From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [[PATCH][XFRM]: Sub-policies broke policy events
Date: Sat, 18 Nov 2006 17:51:59 +0900
Message-ID: <20061118173227.A79B.NAKAM@linux-ipv6.org>
References: <1163770484.5107.20.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:20952 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751471AbWKRIv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Nov 2006 03:51:57 -0500
To: hadi@cyberus.ca
In-Reply-To: <1163770484.5107.20.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Nov 2006 08:34:44 -0500
jamal <hadi@cyberus.ca> wrote:

> 
> Found the cause of my problems. 
> Dave, this is against Linus tree because it is bug fix.
> 
> Nakamura-san please ACK.
> 
> cheers,
> jamal


It looks fine to me. Thanks, Jamal.

Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>



> [XFRM]: Sub-policies broke policy events
> XFRM policy events are broken when sub-policy feature is turned on.
> A simple test to verify this:
> run ip xfrm mon on one window and add then delete a policy on another
> window ..
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> ---
-- 
Masahide NAKAMURA

