From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] DECnet: Fix level1 router hello
Date: Wed, 03 May 2006 23:36:36 -0700 (PDT)
Message-ID: <20060503.233636.79043823.davem@davemloft.net>
References: <4450BB03.4050404@tykepenguin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17105
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751351AbWEDGhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:37:02 -0400
To: patrick@tykepenguin.com
In-Reply-To: <4450BB03.4050404@tykepenguin.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick Caulfield <patrick@tykepenguin.com>
Date: Thu, 27 Apr 2006 13:37:23 +0100

> This patch fixes hello messages sent when a node is a level 1 router. Slightly
> contrary to the spec (maybe) VMS ignores hello messages that do not name
> level2 routers that it also knows about.
> 
> So, here we simply name all the routers that the node knows about rather just
> other level1 routers.
> (I hope the patch is clearer than the description. sorry).
> 
> Patrick
> 
> Signed-off-by: Patrick Caulfield <patrick@tykepenguin.com>

Applied, thanks Patrick.
