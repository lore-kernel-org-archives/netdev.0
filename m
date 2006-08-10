From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] net: drop unused elements from net_proto_family
Date: Wed, 09 Aug 2006 20:50:13 -0700 (PDT)
Message-ID: <20060809.205013.82052478.davem@davemloft.net>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183349.354480139@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28868
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932493AbWHJDuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 23:50:06 -0400
To: shemminger@osdl.org
In-Reply-To: <20060809183349.354480139@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 09 Aug 2006 11:31:41 -0700

> Three values in net_proto_family are defined but never used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied.
