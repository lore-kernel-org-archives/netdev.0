From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] net-next:asix:poll in asix_get_phyid in case phy
 not ready
Date: Tue, 15 Nov 2011 16:41:40 -0500 (EST)
Message-ID: <20111115.164140.2286247969122960824.davem@davemloft.net>
References: <1321377163-26308-1-git-send-email-grundler@chromium.org>
	<1321377163-26308-2-git-send-email-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, freddy@asix.com.tw, grundler@google.com
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321377163-26308-2-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Tue, 15 Nov 2011 09:12:40 -0800

> From: Grant Grundler <grundler@google.com>
> 
> Sometimes the phy isn't ready after reset...poll and pray it will be soon.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied.
