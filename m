From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET] Fix input routing bug
Date: Wed, 18 Oct 2006 20:45:44 -0700 (PDT)
Message-ID: <20061018.204544.107942856.davem@davemloft.net>
References: <20061018083817.GA26179@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patrick@tykepenguin.com, alan.kemmerer@mittalsteel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16783
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423242AbWJSDpf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:45:35 -0400
To: steve@chygwyn.com
In-Reply-To: <20061018083817.GA26179@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <steve@chygwyn.com>
Date: Wed, 18 Oct 2006 09:38:17 +0100

> This patch fixes a silly bug that has been in the input routing code
> for some time. It results in trying to send to a node directly when
> the origin of the packet is via the default router.
> 
> Its been tested by Alan Kemmerer <alan.kemmerer@mittalsteel.com> who
> reported the bug and its a fairly obvious fix for a typo.
> 
> Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
> Signed-off-by: Patrick Caulfield <patrick@tykepenguin.com>

Applied, thanks a lot.
