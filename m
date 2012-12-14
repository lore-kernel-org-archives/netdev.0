From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Fix: kmemleak in tcp_v4/6_syn_recv_sock and dccp_v4/6_request_recv_sock
Date: Fri, 14 Dec 2012 14:34:19 +0100
Message-ID: <2134996.KkfensU2kV@cpaasch-mac>
References: <1355435363-12766-1-git-send-email-christoph.paasch@uclouvain.be> <15583655.5x5gqCFMiY@cpaasch-mac> <1355491565.10504.7.camel@edumazet-glaptop>
Reply-To: Christoph Paasch <christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51902 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649Ab2LNNeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 08:34:25 -0500
In-Reply-To: <1355491565.10504.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 14 December 2012 05:26:05 Eric Dumazet wrote:
> Please correct the changelog to include the right commit, so that we can
> backport it to needed kernels later. This backport could be done by you
> or someone else, don't worry. First step is to get the first patch in
> current Linus tree, but with exact information in changelog.

Ok, will resubmit soon. Thanks for your help.


-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
