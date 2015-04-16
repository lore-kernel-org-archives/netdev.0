From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Drop duplicate declaration of 'ret'
 variable
Date: Thu, 16 Apr 2015 12:15:56 -0400 (EDT)
Message-ID: <20150416.121556.187810209797975762.davem@davemloft.net>
References: <1429192190-31229-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429192190-31229-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 16 Apr 2015 06:49:50 -0700

> A duplicate declaration of 'ret' can result in hiding an error code.
> Drop it.
> 
> Fixes: 17ee3e04ddbf ("net: dsa: Provide additional RMON statistics")
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thank you.
