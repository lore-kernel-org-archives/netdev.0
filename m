From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] drivers/net/cxgb3: Use kzalloc for allocating only
 one thing
Date: Sun, 03 Jan 2010 21:22:49 -0800 (PST)
Message-ID: <20100103.212249.91319016.davem@davemloft.net>
References: <Pine.LNX.4.64.0912190816340.30546@ask.diku.dk>
	<4B3005D5.9070608@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia@diku.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: divy@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753009Ab0ADFWs@vger.kernel.org>
In-Reply-To: <4B3005D5.9070608@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 21 Dec 2009 15:33:41 -0800

> Julia Lawall wrote:
>>
>> From: Julia Lawall <julia@diku.dk>
>>
>> Use kzalloc rather than kcalloc(1,...)
 ...
>> Signed-off-by: Julia Lawall <julia@diku.dk>
>>
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied to net-next-2.6, thanks.
