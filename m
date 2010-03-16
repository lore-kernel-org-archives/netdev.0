From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix lockdep warning on address assignment
Date: Tue, 16 Mar 2010 14:30:03 -0700 (PDT)
Message-ID: <20100316.143003.89856310.davem@davemloft.net>
References: <20100316181433.GB13529@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753570Ab0CPV3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:29:41 -0400
In-Reply-To: <20100316181433.GB13529@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 16 Mar 2010 14:14:33 -0400

> So in the forward porting of various tipc packages, I was constantly
> getting this lockdep warning everytime I used tipc-config to set a network
> address for the protocol:

Applied, thanks!
