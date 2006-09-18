From: Miika Komu <miika@iki.fi>
Subject: Re: [PATCH]:[XFRM] BEET mode
Date: Mon, 18 Sep 2006 10:14:06 +0300 (EEST)
Message-ID: <Pine.SOL.4.64.0609181005200.488@kekkonen.cs.hut.fi>
References: <1158399191.450bc4d7adf76@webmail.hiit.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
	yoshfuji@linux-ipv6.org, rdunlap@xenotime.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twilight.cs.hut.fi ([130.233.40.5]:51437 "EHLO
	twilight.cs.hut.fi") by vger.kernel.org with ESMTP id S965521AbWIRHOc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:14:32 -0400
To: Diego Beltrami <Diego.Beltrami@hiit.fi>
In-Reply-To: <1158399191.450bc4d7adf76@webmail.hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 16 Sep 2006, Diego Beltrami wrote:

> The patch which introduces the BEET mode and which previously was sent to this mailing list is valid also for
> http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.19.git;a=summary
> branch.
> However there are probably some errors in attaching inline the patch to the mail.
> I retry to reattach it. In any case, if there would be some errors, the same patch can be found at the following URL and it works just fine:
>
> ..
>
> For those who haven't been following this discussion, the patch introduces the BEET mode (Bound End-to-End Tunnel) as specified by the ietf draft at the following link:
>
> http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-06.txt
>
> Signed-off-by: Diego Beltrami <diego.beltrami@gmail.com>
> Signed-off-by: Miika Komu     <miika@iki.fi>
> Signed-off-by: Herbert Xu     <herbert@gondor.apana.org.au>
> Signed-off-by: Abhinav Pathak <abhinav.pathak@hiit.fi>
> Signed-off-by: Jeff Ahrenholz <ahrenholz@gmail.com>

Is the patch in the web fine? Diego said that the patch applies fine to 
Dave's branch, but the problem is the email formatting. The patch in the 
web is the same as forwarded to the email list.

I put the patch into a more permanent location:

http://infrahip.hiit.fi/beet/2.6.18/simple-beet-ph-patch-2.6.18
http://infrahip.hiit.fi/beet/2.6.18/simple-beet-ph-patch-2.6.18.md5sum
5cd131d2f15f04d3dc26e360ce3ae38e  simple-beet-ph-patch-2.6.18

-- 
Miika Komu                                       http://www.iki.fi/miika/
