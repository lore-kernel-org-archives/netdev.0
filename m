From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/14] [TIPC] Remove code bloat introduced by print
 buffer rework
Date: Mon, 16 Oct 2006 21:49:23 -0700 (PDT)
Message-ID: <20061016.214923.90120392.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<1160739475673-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56468
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423048AbWJQEtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:49:22 -0400
To: per.liden@ericsson.com
In-Reply-To: <1160739475673-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:47 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch allows the compiler to optimize out any code that tries to
> send debugging output to the null print buffer (TIPC_NULL), a capability
> that was unintentionally broken during the recent print buffer rework.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, thanks.
