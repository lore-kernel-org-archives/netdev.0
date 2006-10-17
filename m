From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/14] [TIPC] Name publication events now delivered in
 chronological order
Date: Mon, 16 Oct 2006 21:56:35 -0700 (PDT)
Message-ID: <20061016.215635.28395552.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<1160739475953-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50123
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423059AbWJQE4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:56:35 -0400
To: per.liden@ericsson.com
In-Reply-To: <1160739475953-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:50 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch tivially re-orders the entries in TIPC's list of local
> publications so that applications will receive publication events
> in the order they were published.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks.
