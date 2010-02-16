From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] X25: Dont let x25_bind use addresses containing
 characters
Date: Mon, 15 Feb 2010 21:55:09 -0800 (PST)
Message-ID: <20100215.215509.251151533.davem@davemloft.net>
References: <1266148845.4731.45.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266148845.4731.45.camel@ibex>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Sun, 14 Feb 2010 23:00:45 +1100

> Addresses should be all digits.
> Stops x25_bind using addresses containing characters.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
