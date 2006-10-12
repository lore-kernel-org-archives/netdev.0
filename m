From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK]: Fix use of wrong skb in do_getlink()
Date: Thu, 12 Oct 2006 01:50:45 -0700 (PDT)
Message-ID: <20061012.015045.122618043.davem@davemloft.net>
References: <452DE379.6010807@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58816
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422831AbWJLIup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 04:50:45 -0400
To: kaber@trash.net
In-Reply-To: <452DE379.6010807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Oct 2006 08:40:57 +0200

> [RTNETLINK]: Fix use of wrong skb in do_getlink()
> 
> skb is the netlink query, nskb is the reply message.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
