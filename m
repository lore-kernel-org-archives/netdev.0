From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] net: Introducing socket mark receive
 socket option
Date: Mon, 02 Mar 2015 15:01:33 -0500 (EST)
Message-ID: <20150302.150133.615535982561377081.davem@davemloft.net>
References: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org
To: eyal.birger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbbCBUBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:01:36 -0500
In-Reply-To: <1425302043-669-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Birger <eyal.birger@gmail.com>
Date: Mon,  2 Mar 2015 15:14:01 +0200

> This patch set introduces a new socket option for fetching the mark
> of skbs passed to sockets as ancillary data.
> 
> A userspace program may wish to receive the mark of packets it
> receives, for example for distinguishing between different TPROXY
> diversion rules to the same userspace proxy socket.
> 
> The patch set includes a minor function renaming.

Series applied, thanks.
