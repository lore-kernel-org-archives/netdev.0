From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] nf_bridge: remove holes in struct
 nf_bridge_info
Date: Thu, 19 Apr 2012 07:52:46 -0700
Message-ID: <20120419075246.0df140e9@s6510.linuxnetplumber.net>
References: <1334827165.2395.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45353 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558Ab2DSOwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 10:52:55 -0400
In-Reply-To: <1334827165.2395.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Apr 2012 11:19:25 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Put use & mask on same location to avoid two holes on 64bit arches
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
