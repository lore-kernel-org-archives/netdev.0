From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6][IPV6]: Introduce the INET6_TW_MATCH macro.
Date: Thu, 31 Jan 2008 05:03:45 -0800 (PST)
Message-ID: <20080131.050345.74892287.davem@davemloft.net>
References: <47A1BF20.7070509@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765640AbYAaNDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:03:25 -0500
In-Reply-To: <47A1BF20.7070509@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 15:29:20 +0300

"0/6"? :-)

> We have INET_MATCH, INET_TW_MATCH and INET6_MATCH to test
> sockets and twbuckets for matching, but ipv6 twbuckets are
> tested manually.
> 
> Here's the INET6_TW_MATCH to help with it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
