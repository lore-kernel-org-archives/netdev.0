From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/3] netpoll/netconsole fixes
Date: Thu, 19 Oct 2006 23:57:19 -0700
Message-ID: <20061019235719.5b30c5d3.akpm@osdl.org>
References: <20061019171541.062261760@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2524 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946253AbWJTG5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 02:57:23 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061019171541.062261760@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Oct 2006 10:15:41 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The netpoll transmit skb management is a mess, it has two
> paths and it's on Txq. These patches try and clean this up.
> 

I got a reject storm when applying the third patch then screwed it up
rather than fixing it up.

A rediff and resend is needed, please.  Make sure it's against the latest
-linus or -davem, thanks.

