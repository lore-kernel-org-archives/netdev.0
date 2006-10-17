From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/14] [TIPC] Add support for Ethernet VLANs
Date: Mon, 16 Oct 2006 21:50:50 -0700 (PDT)
Message-ID: <20061016.215050.131105579.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
	<11607394753517-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57748
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423052AbWJQEuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 00:50:50 -0400
To: per.liden@ericsson.com
In-Reply-To: <11607394753517-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:48 +0200

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> This patch enhances TIPC's Ethernet support to include VLAN interfaces.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>

Applied, more whitespace I had to fixup:

+ git apply --check --whitespace=error-all diff
Adds trailing whitespace.
diff:24: * (in case the message is sent off-node), 
fatal: 1 line adds trailing whitespaces.
