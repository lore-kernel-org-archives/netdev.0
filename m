From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/net/tg3.c: fix a memory leak
Date: Wed, 05 Apr 2006 22:21:18 -0700 (PDT)
Message-ID: <20060405.222118.17348215.davem@davemloft.net>
References: <20060404190935.GB6529@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932090AbWDFFVT@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060404190935.GB6529@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 4 Apr 2006 21:09:35 +0200

> This patch fixes a memory leak (buf wasn't freed) spotted by the 
> Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
