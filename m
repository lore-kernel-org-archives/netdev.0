From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave
 function.
Date: Wed, 19 Oct 2011 13:07:52 +0200
Message-ID: <20111019110752.GA10008@1984>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>
 <CAC52Y8ZvgBVC4_TEBFMALa-xU84PseV6w6sJO64ch+BdAqD2aA@mail.gmail.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903185@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>,
	Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans =?iso-8859-1?Q?Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51033 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993Ab1JSLIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 07:08:00 -0400
Content-Disposition: inline
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903185@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 12:37:51PM +0200, Hans Schillstr=F6m wrote:
> >commit 833656973cde30ba067a994c4802ebab6c9557ee
> >Author: Simon Horman <horms@verge.net.au>
> >Date:   Fri Sep 16 14:11:49 2011 +0900
> >
> >    ipvs: Remove unused return value of protocol state transitions
> >
> >    Acked-by: Julian Anastasov <ja@ssi.bg>
> >    Acked-by Hans Schillstrom <hans@schillstrom.com>
> >    Signed-off-by: Simon Horman <horms@verge.net.au>
> >    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> >
>=20
> From what I can see Simon made a pull request and it was Acked by Pab=
lo 28 Sep
> http://www.spinics.net/lists/netfilter-devel/msg19742.html
>=20
> I have not seen any output to Miller yet...
> but I might be wrong in that case=20

This patch is in my nf-next tree:

http://1984.lsi.us.es/git/?p=3Dnet-next/.git;a=3Dshortlog;h=3Drefs/head=
s/nf-next

David just pulled from my nf tree for bugfix yesterday. I expect to
send him nf-next updates by today.
