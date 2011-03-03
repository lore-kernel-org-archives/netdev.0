From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nex-next] netdevice: make initial group visible to
 userspace
Date: Wed, 02 Mar 2011 21:56:11 -0800 (PST)
Message-ID: <20110302.215611.59690035.davem@davemloft.net>
References: <1296671021-24421-2-git-send-email-ddvlad@rosedu.org>
	<20110225124345.0d691789@nehalam>
	<20110227083911.GA29638@cormyr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net
To: ddvlad@rosedu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754559Ab1CCFze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 00:55:34 -0500
In-Reply-To: <20110227083911.GA29638@cormyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Dogaru <ddvlad@rosedu.org>
Date: Sun, 27 Feb 2011 10:39:12 +0200

> [PATCH net-next] netdevice: make initial group visible to userspace
> 
> INIT_NETDEV_GROUP is needed by userspace, move it outside __KERNEL__
> guards.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

Applied, thanks.
