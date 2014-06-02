From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 1/7] xen-netback: Move grant_copy_op array back into
 struct xenvif.
Date: Mon, 02 Jun 2014 10:22:21 -0700 (PDT)
Message-ID: <20140602.102221.486995077410028646.davem@davemloft.net>
References: <1401706212-8208-2-git-send-email-wei.liu2@citrix.com>
	<538C72F9.5040809@cogentembedded.com>
	<20140602130010.GC6043@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org, ian.campbell@citrix.com,
	david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	paul.durrant@citrix.com, a.j.bennieston@gmail.com,
	andrew.bennieston@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaFBRWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 13:22:24 -0400
In-Reply-To: <20140602130010.GC6043@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Never update patches in this way, as a reply to a thread of
discussion.

When you update a patch, you must cleanly and freshly resubmit the
entire patch series, not just the patch which is changing.

It also really makes no sense to send updates so quickly, as you'll
probably get other feedback for the series meanwhile.  Let it sit for
about a day at least.
