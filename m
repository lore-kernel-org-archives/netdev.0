From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] socket: code style cleanup
Date: Wed, 09 Aug 2006 20:49:22 -0700 (PDT)
Message-ID: <20060809.204922.40143894.davem@davemloft.net>
References: <20060809183138.332023530@localhost.localdomain>
	<20060809183349.177095462@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26820
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932489AbWHJDtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 23:49:15 -0400
To: shemminger@osdl.org
In-Reply-To: <20060809183349.177095462@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 09 Aug 2006 11:31:40 -0700

> Make socket.c conform to current style:
> 	* run through Lindent
> 	* get rid of unneeded casts
> 	* split assignment and comparsion where possible
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks.
