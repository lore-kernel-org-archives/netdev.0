From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: correctly handle qlcnic_alloc_mbx_args
Date: Mon, 04 Jan 2016 17:14:47 -0500 (EST)
Message-ID: <20160104.171447.42775470280476533.davem@davemloft.net>
References: <1451419338-15198-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451419338-15198-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Tue, 29 Dec 2015 15:02:18 -0500

> Since qlcnic_alloc_mbx_args can be failed, 
> return value should be checked.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied, thanks.
