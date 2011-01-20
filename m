From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] netlink: support setting devgroup parameters
Date: Wed, 19 Jan 2011 23:41:04 -0800 (PST)
Message-ID: <20110119.234104.22026625.davem@davemloft.net>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
	<1294997911-13866-3-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, opurdila@ixiacom.com
To: ddvlad@rosedu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739Ab1ATHka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 02:40:30 -0500
In-Reply-To: <1294997911-13866-3-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Dogaru <ddvlad@rosedu.org>
Date: Fri, 14 Jan 2011 11:38:31 +0200

> If a rtnetlink request specifies a negative or zero ifindex and has no
> interface name attribute, but has a group attribute, then the chenges
> are made to all the interfaces belonging to the specified group.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

Applied.
