From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] enic: move wmb closer to where needed: before
 writing posted_index to hw
Date: Fri, 21 Nov 2008 21:29:08 -0800 (PST)
Message-ID: <20081121.212908.125501831.davem@davemloft.net>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
	<20081122003413.15540.83477.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54322
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751632AbYKVF3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 00:29:09 -0500
In-Reply-To: <20081122003413.15540.83477.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Fri, 21 Nov 2008 16:34:13 -0800

> enic: move wmb closer to where needed: before writing posted_index to hw
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
