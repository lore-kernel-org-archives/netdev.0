From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave
 function.
Date: Wed, 19 Oct 2011 19:51:40 +0900
Message-ID: <20111019105139.GB17995@verge.net.au>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53089 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625Ab1JSKvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 06:51:44 -0400
Content-Disposition: inline
In-Reply-To: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2011 at 08:59:49PM +0100, Krzysztof Wilczynski wrote:
> This is to address the following warning during compilation time:
>=20
>   net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_leave=E2=
=80=99:
>   net/netfilter/ipvs/ip_vs_core.c:532: warning: unused variable =E2=80=
=98cs=E2=80=99
>=20
> This variable is indeed no longer in use.

Thanks, applied to ipvs-next,
currently living at git://github.com/horms/ipvs-next.git
