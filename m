From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/14] [TIPC] Can now list multicast link on an
 isolated network node
Date: Mon, 16 Oct 2006 21:58:09 -0700 (PDT)
Message-ID: <20061016.215809.82375874.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394753889-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52939
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423064AbWJQE6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:58:08 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394753889-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:52 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch fixes a minor bug that prevents "tipc-config -l" from
> displaying the multicast link if a TIPC node has never successfully
> established at least one unicast link.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks.
