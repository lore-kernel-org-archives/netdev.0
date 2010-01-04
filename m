From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] drivers/net/can: Correct NULL test
Date: Sun, 03 Jan 2010 21:44:12 -0800 (PST)
Message-ID: <20100103.214412.50599561.davem@davemloft.net>
References: <Pine.LNX.4.64.0912272227290.20548@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753253Ab0ADFoR@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0912272227290.20548@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sun, 27 Dec 2009 22:27:44 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> Test the just-allocated value for NULL rather than some other value.
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
