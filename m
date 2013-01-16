From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: set coalesce parameters on all queues
Date: Wed, 16 Jan 2013 15:28:53 -0500 (EST)
Message-ID: <20130116.152853.1951022929656410901.davem@davemloft.net>
References: <1358262910-23121-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com,
	linux-kernel@vger.kernel.org, steved@us.ibm.com, toml@us.ibm.com
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358262910-23121-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 13:15:10 -0200

> The coalesce parameters was set only on the first queue, which caused
> interrupt rates to be larger on all the other queues.
> 
> This patch allows interrupt rates to be reduced for certain workloads
> and colaesce parameters by 41%.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied, thanks.
