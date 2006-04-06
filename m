From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/core/net-sysfs.c: fix an off-by-21-or-49 error
Date: Wed, 05 Apr 2006 22:19:57 -0700 (PDT)
Message-ID: <20060405.221957.47173834.davem@davemloft.net>
References: <20060404190742.GA6529@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932065AbWDFFUF@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060404190742.GA6529@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 4 Apr 2006 21:07:42 +0200

> This patch fixes an off-by-21-or-49 error ;-) spotted by the Coverity 
> checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
