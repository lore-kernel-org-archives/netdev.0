From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for April 7 (net/core/dev_addr_lists)
Date: Wed, 07 Apr 2010 16:46:44 -0700 (PDT)
Message-ID: <20100407.164644.96927208.davem@davemloft.net>
References: <20100407095845.f29ebf48.randy.dunlap@oracle.com>
	<1270661889.8141.45.camel@edumazet-laptop>
	<20100407105049.0f812b27.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100407105049.0f812b27.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 7 Apr 2010 10:50:49 -0700

> On Wed, 07 Apr 2010 19:38:09 +0200 Eric Dumazet wrote:
> 
>> [PATCH net-next-2.6] net: include linux/proc_fs.h in dev_addr_lists.c
>> 
>> As pointed by Randy Dunlap, we must include linux/proc_fs.h in
>> net/core/dev_addr_lists.c, regardless of CONFIG_PROC_FS
>> 
>> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>, 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks everyone.
