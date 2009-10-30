From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Fri, 30 Oct 2009 01:44:54 -0700 (PDT)
Message-ID: <20091030.014454.175357008.davem@davemloft.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B9503CA@zin33exm22.fsl.freescale.net>
	<20091030.005924.56385149.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B9503DF@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756599AbZJ3Ioa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:44:30 -0400
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B9503DF@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Fri, 30 Oct 2009 14:12:22 +0530

> We were referring to the logs shown on the gitweb.
> The tree log does not show this commit. 
> (search for this commit id failed)
> http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Fdavem%2Fnet-next-2.6.git
> &a=search&h=29906f6a427d2004a515ebbcdc7b28bae8f6c19c&st=commit&s=e72701a
> cbe0b35e52d3f04d442837c06b4e64f1c
> 
> Whereas, the log for the file does show the commit.
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=histo
> ry;f=drivers/net/fsl_pq_mdio.c;h=6ac4648669728421b934d32646ffbb626128387
> 6;hb=HEAD
> 
> Why is there such a mismatch on the tree itself?

If you are using HTTP for accessing my GIT tree(s) that's your
problem.

I do not update the web based GIT information when I push into my
tree(s), only the GIT and SSH protocols are reliable ways to clone and
access my tree(s).
