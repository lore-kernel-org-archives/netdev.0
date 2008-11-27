From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sctp: fix missing label when PROC_FS=n
Date: Thu, 27 Nov 2008 15:31:08 -0800 (PST)
Message-ID: <20081127.153108.211641463.davem@davemloft.net>
References: <20081127121824.5b3515c9.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081127121824.5b3515c9.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 27 Nov 2008 12:18:24 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix missing label when CONFIG_PROC_FS=n:
> 
> net/sctp/protocol.c: In function 'sctp_proc_init':
> net/sctp/protocol.c:106: error: label 'out_nomem' used but not defined
> make[3]: *** [net/sctp/protocol.o] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks a lot Randy.
