From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cxgb3: fix device opening error path
Date: Mon, 25 Oct 2010 12:15:24 -0700 (PDT)
Message-ID: <20101025.121524.183040367.davem@davemloft.net>
References: <20101025173502.27055.847.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101025173502.27055.847.stgit@speedy5.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 25 Oct 2010 10:35:02 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Only negative return from bind_qsets() should be considered an error and
> propagated.
> It fixes an issue reported by IBM on P Series platform.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Applied.
