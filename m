From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/13] drivers/net/ehea: Remove redundant test
Date: Thu, 25 Dec 2008 18:04:01 -0800 (PST)
Message-ID: <20081225.180401.17507583.davem@davemloft.net>
References: <Pine.LNX.4.64.0812211637370.9555@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752717AbYLZCEY@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0812211637370.9555@pc-004.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sun, 21 Dec 2008 16:37:55 +0100 (CET)

> In each case, vpage is checked not to be NULL just after it is initialized
> at the beginning of each loop iteration.

Applied.
