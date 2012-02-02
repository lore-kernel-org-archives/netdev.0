From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/hyperv: Fix the page buffer when an RNDIS
 message goes beyond page boundary
Date: Thu, 02 Feb 2012 14:50:49 -0500 (EST)
Message-ID: <20120202.145049.1266443194879118640.davem@davemloft.net>
References: <1328203080-801-1-git-send-email-haiyangz@microsoft.com>
	<1328203080-801-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328203080-801-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu,  2 Feb 2012 09:18:00 -0800

> There is a possible data corruption if an RNDIS message goes beyond page
> boundary in the sending code path. This patch fixes the problem.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
