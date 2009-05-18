From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc95xx: strip ethernet fcs (crc) on receive path
Date: Sun, 17 May 2009 21:06:42 -0700 (PDT)
Message-ID: <20090517.210642.239781593.davem@davemloft.net>
References: <1242245441-15027-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750706AbZEREGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:06:45 -0400
In-Reply-To: <1242245441-15027-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Wed, 13 May 2009 22:10:41 +0200

> The smsc95xx driver was forwarding the trailing fcs on received frames
> up the stack leading to confusion in tcpdump.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied to net-next-2.6
