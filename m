From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: explain netns notifiers a little better
Date: Mon, 20 Jul 2009 08:04:09 -0700 (PDT)
Message-ID: <20090720.080409.248628533.davem@davemloft.net>
References: <1247674594.10754.20.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751631AbZGTPEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 11:04:04 -0400
In-Reply-To: <1247674594.10754.20.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 15 Jul 2009 18:16:34 +0200

> Eric explained this to me -- and afterwards the comment
> made sense, but not before. Add the the critical point
> about interfaces having to be gone from the netns before
> subsys notifiers are called.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied to net-next-2.6
