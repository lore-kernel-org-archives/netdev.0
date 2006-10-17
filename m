From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/14] [TIPC] Added subscription cancellation capability
Date: Mon, 16 Oct 2006 22:00:19 -0700 (PDT)
Message-ID: <20061016.220019.74384701.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394754005-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chenli@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53949
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423067AbWJQFAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:00:21 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394754005-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:53 +0200

> From: Lijun Chen <chenli@nortel.com>
> 
> This patch allows a TIPC application to cancel an existing
> topology service subscription by re-requesting the subscription
> with the TIPC_SUB_CANCEL filter bit set.  (All other bits of
> the cancel request must match the original subscription request.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, but had some trailing whitespace additions to cleanup
and would you please ask all patch authors to provide proper
signed-off-by lines in the future?  Thanks.
