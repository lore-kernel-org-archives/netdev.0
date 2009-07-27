From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deprecate print_mac
Date: Sun, 26 Jul 2009 19:48:52 -0700 (PDT)
Message-ID: <20090726.194852.219170593.davem@davemloft.net>
References: <1247671403.10754.8.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56699
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755315AbZG0Csq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:48:46 -0400
In-Reply-To: <1247671403.10754.8.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 15 Jul 2009 17:23:23 +0200

> We've had %pM for long enough now, time to deprecate
> print_mac() and remove the __maybe_unused attribute
> from DECLARE_MAC_BUF so that variables declared with
> that can be found and removed. Otherwise people are
> putting in new users of print_mac().
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied.
