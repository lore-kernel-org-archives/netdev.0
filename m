From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] net socket family patches
Date: Wed, 09 Aug 2006 17:06:41 -0700 (PDT)
Message-ID: <20060809.170641.02297593.davem@davemloft.net>
References: <20060809183138.332023530@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6880
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932085AbWHJAGt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 20:06:49 -0400
To: shemminger@osdl.org
In-Reply-To: <20060809183138.332023530@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 09 Aug 2006 11:31:38 -0700

> These patches cleanup the net socket family interface and
> convert it to RCU. This is new stuff that should go into 2.6.19
> (if it is ready). Andrew could you put it in -mm as well?

Andrew pulls net-2.6.19 so there is no need to ask him to
put networking patches explicitly into -mm
