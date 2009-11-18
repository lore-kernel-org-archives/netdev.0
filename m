From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/16] drivers/net/via-velocity.c: remove exceptional &
 on function name
Date: Wed, 18 Nov 2009 10:51:52 -0800 (PST)
Message-ID: <20091118.105152.188789288.davem@davemloft.net>
References: <Pine.LNX.4.64.0911181923540.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, arnd@arndb.de,
	joe@perches.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932515AbZKRSxL@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0911181923540.20943@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Wed, 18 Nov 2009 19:24:13 +0100 (CET)

> In this file, function names are otherwise used as pointers without &.
  ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
