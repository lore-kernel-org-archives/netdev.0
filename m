From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 01/26] bridge: netfilter: checkpatch data type fixes
Date: Wed, 6 Jul 2016 14:32:48 -0700
Message-ID: <20160706143248.3c5f6266@samsung9>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
	<1467815048-2240-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  6 Jul 2016 16:23:43 +0200
Pablo Neira Ayuso <pablo@netfilter.org> wrote:

> From: Tobin C Harding <me@tobin.cc>
> 
> checkpatch produces data type 'checks'.
> 
> This patch amends them by changing, for example:
> uint8_t -> u8
> 
> Signed-off-by: Tobin C Harding <me@tobin.cc>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks, for fixing this. This is old.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
