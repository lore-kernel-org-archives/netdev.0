From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: da.s_net not copied but assigned to itself in
 aarp_rcv()
Date: Fri, 15 Jan 2010 01:49:43 -0800 (PST)
Message-ID: <20100115.014943.39860500.davem@davemloft.net>
References: <4B4F7F4B.8000302@gmail.com>
	<20100114210001.GE20221@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757384Ab0AOJti@vger.kernel.org>
In-Reply-To: <20100114210001.GE20221@ghostprotocols.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 14 Jan 2010 19:00:01 -0200

> Em Thu, Jan 14, 2010 at 09:32:11PM +0100, Roel Kluin escreveu:
>> da.s_net was not copied but assigned to itself.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Looks right, must be there for ages...
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, please always CC: on networking patches.

Thanks.
