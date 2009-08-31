From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH next] sky2: Create buffer alloc and free helpers
Date: Mon, 31 Aug 2009 10:29:46 -0700
Message-ID: <20090831102946.409ec72e@nehalam>
References: <4A992974.1060308@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41249 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752183AbZHaRaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 13:30:06 -0400
In-Reply-To: <4A992974.1060308@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Aug 2009 22:13:24 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> Refactor similar two sections of code that free buffers into one.
> Only call tx_init if all buffer allocations succeed.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>


Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
