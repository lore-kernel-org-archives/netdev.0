From: Praveen Madhavan <praveenm@chelsio.com>
Subject: Re: [PATCH 0/2] Remove T4 FCoE support
Date: Fri, 16 Jan 2015 10:02:59 +0530
Message-ID: <20150116042616.GA1264@fcoe-test11>
References: <cover.1421328605.git.praveenm@chelsio.com>
 <20150115.140453.871607276763972458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<JBottomley@parallels.com>, <hch@infradead.org>,
	<hariprasad@chelsio.com>, <varun@chelsio.com>, <hare@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20848 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbbAPEdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 23:33:43 -0500
Content-Disposition: inline
In-Reply-To: <20150115.140453.871607276763972458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2015 at 02:04:53PM -0500, David Miller wrote:
> From: Praveen Madhavan <praveenm@chelsio.com>
> Date: Thu, 15 Jan 2015 19:15:50 +0530
> 
> > These patches removes FCoE support for chelsio T4 adapter.
> > Please apply on net-next since depends on previous commits.
> 
> Why is it being removed?  You have to state this in the
> commit log messages at a minimum.
>
We found a subtle issue with FCoE on T4 very late in the game 
and decided not to productize FCoE on T4 and therefore there 
are no customers that will be impacted by this change. FCoE is
supported on T5 cards.
Sorry about that, not mentioning in commit log. Can i resend this 
patch with updated commit log?
 
