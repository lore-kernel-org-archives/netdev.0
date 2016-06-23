From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Maxim/driver: Add driver for maxim ds26522
Date: Thu, 23 Jun 2016 10:59:15 -0400 (EDT)
Message-ID: <20160623.105915.1184538161171070695.davem@davemloft.net>
References: <1466644185-6081-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oss@buserror.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xiaobo.xie@nxp.com
To: qiang.zhao@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466644185-6081-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhao Qiang <qiang.zhao@nxp.com>
Date: Thu, 23 Jun 2016 09:09:45 +0800

> +MODULE_DESCRIPTION(DRV_DESC);

There is no definition of DRV_DESC, so this makes it look like
you didn't even compile this driver.
