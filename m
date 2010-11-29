From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] drivers/net: Remove unnecessary [kv][mcz]alloc
 casts
Date: Sun, 28 Nov 2010 17:26:57 -0800 (PST)
Message-ID: <20101128.172657.193710679.davem@davemloft.net>
References: <cover.1290934782.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290934782.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 28 Nov 2010 01:05:42 -0800

> These are the last remaining alloc casts in drivers/net...
> 
> Joe Perches (4):
>   netxen: remove unnecessary [kv][mcz]alloc casts
>   qlcnic: remove unnecessary [kv][mcz]alloc casts
>   vxge: remove unnecessary [kv][mcz]alloc casts
>   zd1211rw: remove unnecessary [kv][mcz]alloc casts

All applied, using v2 of patch #4.

Thanks.
