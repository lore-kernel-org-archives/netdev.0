From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Sat, 14 Apr 2007 19:10:38 +0200
Message-ID: <46210B0E.2040209@trash.net>
References: <461DC70B.4000500@trash.net>	<20070413.161635.26523891.davem@davemloft.net>	<17953.1560.855914.274514@cargo.ozlabs.ibm.com> <20070414.100441.15000708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63982 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbXDNRME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 13:12:04 -0400
In-Reply-To: <20070414.100441.15000708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Paul Mackerras <paulus@samba.org>
> Date: Sun, 15 Apr 2007 02:49:28 +1000
> 
> 
>>I didn't see the patch (the message that this is a reply to is the
>>first one that I have seen in this thread), so I can't comment on it.
> 
> 
> Here is Patrick McHardy's patch:
> 
> [..]


I haven't heard back from Bartek yet. In case the patch is correct,
ppp_synctty seems to need the same fix.

