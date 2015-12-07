From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] cxgb3: Convert simple_strtoul to kstrtox
Date: Mon, 07 Dec 2015 16:49:58 -0500 (EST)
Message-ID: <20151207.164958.995538780250171482.davem@davemloft.net>
References: <1449493893-18055-1-git-send-email-clabbe.montjoie@gmail.com>
	<1449493893-18055-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449493893-18055-2-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Mon,  7 Dec 2015 14:11:33 +0100

> the simple_strtoul function is obsolete. This patch replace it by
> kstrtox.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Applied, thanks.
