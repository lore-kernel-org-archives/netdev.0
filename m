From: David Miller <davem@davemloft.net>
Subject: Re: sctp: Do not reset the packet during sctp_packet_config().
Date: Fri, 17 Sep 2010 16:48:47 -0700 (PDT)
Message-ID: <20100917.164847.32717043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750782Ab0IQXs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:48:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Vlad I ran out of patience and applied this directly to my
net-2.6 tree

Just FYI...
