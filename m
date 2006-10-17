From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/14] [TIPC] Unrecognized configuration command now
 returns error message
Date: Mon, 16 Oct 2006 22:01:06 -0700 (PDT)
Message-ID: <20061016.220106.84974091.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394751662-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55741
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423071AbWJQFBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:01:05 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394751662-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:54 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch causes TIPC to return an error message when it receives
> an unrecognized configuration command.  (Previously, the sender
> received no feedback.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied.
