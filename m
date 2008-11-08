From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: trivial endian annotation in debug statement
Date: Fri, 07 Nov 2008 23:38:33 -0800 (PST)
Message-ID: <20081107.233833.127193563.davem@davemloft.net>
References: <1226106727.11596.59.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752545AbYKHHie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 02:38:34 -0500
In-Reply-To: <1226106727.11596.59.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Fri, 07 Nov 2008 17:12:07 -0800

> Use htonl rather than ntohl on a u32.
> net/tipc/name_table.c:557:2: warning: cast to restricted __be32
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied thanks!
