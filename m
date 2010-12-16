From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv8] net: Add batman-adv meshing protocol
Date: Thu, 16 Dec 2010 14:01:53 -0800 (PST)
Message-ID: <20101216.140153.232733922.davem@davemloft.net>
References: <1292275168-19882-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	greg@kroah.com
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753883Ab0LPWBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:01:25 -0500
In-Reply-To: <1292275168-19882-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Mon, 13 Dec 2010 22:19:28 +0100

> B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
> protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
> wireless. See http://www.open-mesh.org/ for more information and user space
> tools.
> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>

Applied, thanks Sven.

How do you want to take care of the copy that still lives under
staging?

Greg, any preferences on your end?

I'm more than happy to do the removal from my net-next-2.6 tree
since the bonafide copy of net/batman-adv is now there.

