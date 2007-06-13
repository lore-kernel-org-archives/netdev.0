From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tulip: Convert to generic boolean
Date: Wed, 13 Jun 2007 15:53:27 -0400
Message-ID: <46704B37.5020509@garzik.org>
References: <20070519202047.26710.93680.sendpatchset@thinktank.campus.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: val_henson@linux.intel.com, tulip-users@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Richard Knutsson <ricknu-0@student.ltu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39011 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621AbXFMTxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 15:53:35 -0400
In-Reply-To: <20070519202047.26710.93680.sendpatchset@thinktank.campus.ltu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Knutsson wrote:
> Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
> ---
> Compile-tested with all(yes|mod|no)config on x86(|_64) & sparc(|64)
> Diffed against Linus' git-tree.
> 
>  de4x5.c |   98 ++++++++++++++++++++++++++++++++--------------------------------
>  de4x5.h |    9 -----
>  2 files changed, 49 insertions(+), 58 deletions(-)

applied to #upstream


