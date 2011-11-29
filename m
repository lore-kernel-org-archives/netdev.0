From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: sja1000_isa: fix "limited range" compiler warnings
Date: Tue, 29 Nov 2011 18:29:07 -0500 (EST)
Message-ID: <20111129.182907.1183196314960241442.davem@davemloft.net>
References: <4ECE0993.6050902@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, linux-can@vger.kernel.org
To: wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ECE0993.6050902@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 24 Nov 2011 10:08:35 +0100

> This patch fixes the compiler warnings: "comparison is always
> false due to limited range of data type" by using "0xff" instead
> of "-1" for unsigned values.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied to net-next, thanks.
