From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 1/3] fsl_pq_mdio: Fix compiler/sparse warnings (part 1)
Date: Thu, 5 Nov 2009 15:38:26 +0300
Message-ID: <20091105123826.GA2262@oksana.dev.rtsoft.ru>
References: <20091104225256.GA29537@oksana.dev.rtsoft.ru>
 <9F4C7D19E8361D4C94921B95BE08B81B95069E@zin33exm22.fsl.freescale.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Fleming Andy-AFLEMING <afleming@freescale.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:2406 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755119AbZKEMiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 07:38:21 -0500
Content-Disposition: inline
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B95069E@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 05, 2009 at 11:11:56AM +0530, Kumar Gopalpet-B05799 wrote:
[...]
> >HI Anton, thanks for the changes. I have only one concern, has 
> >this code been tried for ucc_geth ? I remember I had some 
> >issues with getting the ucc_geth mdio also working. I will 
> >take in these changes and try at my end for ucc_geth.
> 
> Sorry, if my earlier statement was confusing. What I meant was with
> similar changes as Anton's changes
> I had some issues with ucc_geth mdio ( may be Anton's changes don't have
> that issue).

Nope, I see no issues on MPC8360E-MDS using ucc_geth and fsl_pq_mdio
drivers.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
