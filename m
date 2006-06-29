From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [TIPC] Improve response to requests for node/link
 information
Date: Thu, 29 Jun 2006 12:34:19 -0700 (PDT)
Message-ID: <20060629.123419.45513325.davem@davemloft.net>
References: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
	<11514964721454-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11988
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932322AbWF2TeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 15:34:21 -0400
To: per.liden@ericsson.com
In-Reply-To: <11514964721454-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Wed, 28 Jun 2006 14:07:51 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Now allocates reply space for "get links" request based on number of actual
> links, not number of potential links.  Also, limits reply to "get links" and
> "get nodes" requests to 32KB to match capabilities of tipc-config utility
> that issued request.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks.
