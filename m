From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RESEND] iproute2: GRE over IPv6 tunnel support.
Date: Sat, 28 Sep 2013 10:14:48 -0700
Message-ID: <20130928101448.1a3c3b29@nehalam.linuxnetplumber.net>
References: <20130928113251.75738a49@comp1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:46211 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab3I1ROw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 13:14:52 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so3823226pbc.37
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 10:14:52 -0700 (PDT)
In-Reply-To: <20130928113251.75738a49@comp1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Sep 2013 11:32:51 +0400
Dmitry Kozlov <xeb@mail.ru> wrote:

> GRE over IPv6 tunnel support.
> 
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> ---
>  ip/Makefile    |   3 +-
>  ip/ip6tunnel.c | 131 ++++++++++++++++---
>  ip/iplink.c    |   7 +-
>  ip/link_gre6.c | 398 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 516 insertions(+), 23 deletions(-)
>  create mode 100644 ip/link_gre6.c
> 

Please send an additional patch to update the man page.
