From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] X25: Fix x25_create errors for bad protocol and
 ENOBUFS
Date: Mon, 15 Feb 2010 21:55:03 -0800 (PST)
Message-ID: <20100215.215503.267631768.davem@davemloft.net>
References: <1266148811.4731.43.camel@ibex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrew.hendry@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266148811.4731.43.camel@ibex>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Hendry <andrew.hendry@gmail.com>
Date: Sun, 14 Feb 2010 23:00:11 +1100

> alloc_socket failures should return -ENOBUFS
> a bad protocol should return -EINVAL
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
