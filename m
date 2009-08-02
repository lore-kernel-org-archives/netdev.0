From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/15] drivers/atm: Use DIV_ROUND_CLOSEST
Date: Sun, 02 Aug 2009 12:55:52 -0700 (PDT)
Message-ID: <20090802.125552.192054201.davem@davemloft.net>
References: <Pine.LNX.4.64.0908021048280.15557@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753567AbZHBTzs@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0908021048280.15557@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sun, 2 Aug 2009 10:48:45 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> The kernel.h macro DIV_ROUND_CLOSEST performs the computation (x + d/2)/d
> but is perhaps more readable.

Applied.
