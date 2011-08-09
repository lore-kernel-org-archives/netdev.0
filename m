From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 08:50:49 -0700 (PDT)
Message-ID: <20110809.085049.747100276988072226.davem@davemloft.net>
References: <1312904711-1855-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sandeep.Kumar@freescale.com, wangshaoyan.pt@taobao.com
To: stufever@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312904711-1855-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stufever@gmail.com
Date: Tue,  9 Aug 2011 23:45:11 +0800

> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
> 
>   drivers/net/gianfar_ethtool.c:765: warning: the frame size of 2048 bytes is larger than 1024 bytes
> 
> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>

Would you be so kind as to actually acknowledge in some way the person
who found all the bugs in your first version of this patch? :-/
