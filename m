From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 08:01:04 -0700
Message-ID: <1363964464.4431.67.camel@edumazet-glaptop>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com>
	 <1363962193.4431.59.camel@edumazet-glaptop>
	 <63463136-FE5B-462D-9259-53DD5AC61BDB@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Collins <benmcollins13@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <63463136-FE5B-462D-9259-53DD5AC61BDB@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-03-22 at 10:50 -0400, Ben Collins wrote:

> 
>         NETIF_F_LLTX_BIT,               /* LockLess TX - deprecated. Please */
>                                         /* do not use LLTX in new drivers */

Yes, but this is the current way to do that.

Unless you design a complete new layer to replace it.
