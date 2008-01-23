From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/12 net-2.6.25] [NETNS]: Correct namespace for
 connect-time routing.
Date: Tue, 22 Jan 2008 23:51:16 -0800 (PST)
Message-ID: <20080122.235116.133428977.davem@davemloft.net>
References: <479612BE.8030409@openvz.org>
	<1201074387-7366-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752841AbYAWHvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:51:09 -0500
In-Reply-To: <1201074387-7366-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 23 Jan 2008 10:46:25 +0300

> ip_route_connect and ip_route_newports are a part of routing API presented to
> the socket layer. The namespace is available inside them through a socket.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.
