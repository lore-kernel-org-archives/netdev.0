From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: correctly check failed allocation
Date: Sun, 18 Oct 2015 19:37:51 -0700 (PDT)
Message-ID: <20151018.193751.824570854056726678.davem@davemloft.net>
References: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Thu, 15 Oct 2015 18:02:28 +0000

> Since vzalloc can be failed in memory pressure,
> writes -ENOMEM to xenstore to indicate error.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied.
