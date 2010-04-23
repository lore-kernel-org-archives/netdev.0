From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Fri, 23 Apr 2010 18:02:33 -0400
Message-ID: <1272060153.8918.8.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:33825 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758366Ab0DWWCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:02:39 -0400
Received: by pwj9 with SMTP id 9so7282659pwj.19
        for <netdev@vger.kernel.org>; Fri, 23 Apr 2010 15:02:38 -0700 (PDT)
In-Reply-To: <1272014825.7895.7851.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-23 at 11:27 +0200, Eric Dumazet wrote:

> 
> Lets see how it improves thing for Jamal benchs ;)


Ive done a setup with the last patch from Changli + net-next - I will
post test results tomorrow AM.

cheers,
jamal

