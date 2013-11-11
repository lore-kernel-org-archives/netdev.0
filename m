From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] prandom fixes/improvements
Date: Mon, 11 Nov 2013 20:44:32 +0100
Message-ID: <20131111194432.GA3043@order.stressinduktion.org>
References: <cover.1384160397.git.dborkman@redhat.com> <20131111.143341.148954332177473990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dborkman@redhat.com, shemminger@networkplumber.org,
	fweimer@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36078 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab3KKTod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:44:33 -0500
Content-Disposition: inline
In-Reply-To: <20131111.143341.148954332177473990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 02:33:41PM -0500, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Mon, 11 Nov 2013 12:20:31 +0100
> 
> > It would be great if you could still consider this series that fixes and
> > improves prandom for 3.13. We have sent it to netdev as prandom() originally
> > came from net/core/utils.c and networking is its main user. For a detailled
> > description, please see individual patches.
> 
> Ok, series applied, I'll give Linus the merge conflict resolution
> instructions.

We would also suggest to push Patch #1 to -stable.

Thank you,

  Hannes
