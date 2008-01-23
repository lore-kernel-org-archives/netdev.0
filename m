From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12 net-2.6.25] [NETNS]: Add namespace for ICMP
 replying code.
Date: Tue, 22 Jan 2008 23:51:30 -0800 (PST)
Message-ID: <20080122.235130.84789113.davem@davemloft.net>
References: <479612BE.8030409@openvz.org>
	<1201074387-7366-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753699AbYAWHvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:51:25 -0500
In-Reply-To: <1201074387-7366-3-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 23 Jan 2008 10:46:27 +0300

> All needed API is done, the namespace is available when required from the
> device on the DST entry from the incoming packet. So, just replace init_net
> with proper namespace.
> 
> Other protocols will follow.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
