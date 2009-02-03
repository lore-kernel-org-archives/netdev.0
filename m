From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sunrpc: fix rdma dependencies
Date: Tue, 03 Feb 2009 15:20:58 -0800 (PST)
Message-ID: <20090203.152058.182816628.davem@davemloft.net>
References: <200902030112.n131CNiq010549@imap1.linux-foundation.org>
	<4988C17B.1030902@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	bfields@fieldses.org, neilb@suse.de, rolandd@cisco.com,
	netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755764AbZBCXVe@vger.kernel.org>
In-Reply-To: <4988C17B.1030902@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 03 Feb 2009 14:13:15 -0800

> Fix sunrpc/rdma build dependencies.
> Survives 12 build combinations of INET, IPV6, SUNRPC,
> INFINIBAND, and INFINIBAND_ADDR_TRANS.
 ...
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
