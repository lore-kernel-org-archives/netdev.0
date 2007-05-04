From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
Date: Fri, 04 May 2007 21:41:49 +0200
Message-ID: <1178307709.2767.19.camel@lappy>
References: <20070504102651.923946304@chello.nl>
	 <20070504.122716.31641374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no, tgraf@suug.ch,
	James.Bottomley@SteelEye.com, michaelc@cs.wisc.edu,
	akpm@linux-foundation.org, phillips@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:9938 "EHLO
	amsfep18-int.chello.nl" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1422665AbXEDTqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:46:49 -0400
In-Reply-To: <20070504.122716.31641374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 12:27 -0700, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Fri, 04 May 2007 12:26:51 +0200
> 
> > There is a fundamental deadlock associated with paging;
> 
> I know you'd really like people like myself to review this work, but a
> set of 40 patches is just too much to try and digest at once
> especially when I have other things going on.

I realize this, however I expected you to mainly look at the the 10
network related patches, namely: 11/40 - 20/40.

I know they build upon the previous 10 patches, which are mostly VM, and
you seem to have an interest in that as well, so that would be 20
patches to look at. Still a sizable set.

How would you prefer I present these?

The other patches are NFS and iSCSI, I'd not expect you to review those
in depth.


