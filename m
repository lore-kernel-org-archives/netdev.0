From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 2/2] smsc95xx: strip ethernet fcs (crc) on receive path
Date: Sun, 17 May 2009 19:58:00 +0100
Message-ID: <OF2E24394D.CD021461-ON802575B9.0067E639-802575B9.00682CC7@smsc.com>
References: <1242245441-15027-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Peter Korsgaard <jacmet@gmail.com>,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2744 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752250AbZEQS6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 14:58:15 -0400
In-Reply-To: <1242245441-15027-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Korsgaard <jacmet@gmail.com> wrote on 13/05/2009 21:10:41:

> The smsc95xx driver was forwarding the trailing fcs on received frames
> up the stack leading to confusion in tcpdump.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Tested-by: Steve Glendinning <steve.glendinning@smsc.com>
Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

