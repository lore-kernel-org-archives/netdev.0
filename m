From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: ipv6_select_ident() returns a __be32
Date: Mon, 25 May 2015 17:22:11 -0700
Message-ID: <20150526002211.GA2073011@devbig242.prn2.facebook.com>
References: <201505260544.3guHqjoi%fengguang.wu@intel.com>
 <1432594941.4060.198.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: kbuild test robot <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39027 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750903AbbEZAWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 20:22:24 -0400
Content-Disposition: inline
In-Reply-To: <1432594941.4060.198.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2015 at 04:02:21PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> ipv6_select_ident() returns a 32bit value in network order.
> 
> Fixes: 286c2349f666 ("ipv6: Clean up ipv6_select_ident() and ip6_fragment()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
Thanks for fixing it.

Acked-by: Martin KaFai Lau <kafai@fb.com>
