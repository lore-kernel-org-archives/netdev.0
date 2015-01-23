From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: handle more gso types
Date: Fri, 23 Jan 2015 10:56:27 -0800
Message-ID: <1422039387.29618.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422021446.29618.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx98Hem6+L1gt9ZK-JDs0f=aNdJakFnGWspoTzdYcAcpBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:44736 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbAWS43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 13:56:29 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so8770536ieb.4
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 10:56:28 -0800 (PST)
In-Reply-To: <CA+mtBx98Hem6+L1gt9ZK-JDs0f=aNdJakFnGWspoTzdYcAcpBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-23 at 10:33 -0800, Tom Herbert wrote:

> Is there any reason not to add NETIF_F_GSO_UDP_TUNNEL_CSUM and
> NETIF_F_GSO_UDP_REMCSUM also?

I guess there is no reasons, others than me not catching with all these
extra features, and me not being able to test them.
