From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fddi: skfp: use %p format specifier for addresses
 rather than %x
Date: Wed, 21 Dec 2016 15:35:02 -0500 (EST)
Message-ID: <20161221.153502.532764084800806773.davem@davemloft.net>
References: <20161221160323.27780-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221160323.27780-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 21 Dec 2016 16:03:23 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix: Addresses should be printed using the %p format specifier
> rather than using %x.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
