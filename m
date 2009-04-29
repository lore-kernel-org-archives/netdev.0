From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
 sk_buff state
Date: Wed, 29 Apr 2009 15:44:06 -0700 (PDT)
Message-ID: <20090429.154406.231161665.davem@davemloft.net>
References: <20090429151440.GA14266@cuplxvomd02.corp.sa.net>
	<20090429.145338.149717676.davem@davemloft.net>
	<20090429222809.GA1949@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dvomlehn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59142
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763297AbZD2WoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 18:44:13 -0400
In-Reply-To: <20090429222809.GA1949@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <dvomlehn@cisco.com>
Date: Wed, 29 Apr 2009 15:28:09 -0700

> Still, let us back up to technical specifics.

The specifics are that if you showed me something that
added a "u16", at most, I'd go to bat for you and support
your work going upstream.

We could find a way to squeeze that into the existing
structure with little or even no size increase.
