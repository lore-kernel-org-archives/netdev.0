From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: correctly handling failed allocation
Date: Mon, 04 Jan 2016 17:19:00 -0500 (EST)
Message-ID: <20160104.171900.1006206453660470786.davem@davemloft.net>
References: <1451427611-32338-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451427611-32338-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Tue, 29 Dec 2015 17:20:11 -0500

> Since t4_alloc_mem can be failed in memory pressure,
> if not properly handled, NULL dereference could be happened.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied.
