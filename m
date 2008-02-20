From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NETNS]: Namespace leak in pneigh_lookup.
Date: Wed, 20 Feb 2008 00:26:27 -0800 (PST)
Message-ID: <20080220.002627.118759776.davem@davemloft.net>
References: <1203426758-27813-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753474AbYBTIZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 03:25:51 -0500
In-Reply-To: <1203426758-27813-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 19 Feb 2008 16:12:38 +0300

> release_net is missed on the error path in pneigh_lookup.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks a lot.
