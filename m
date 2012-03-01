From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 15:42:58 -0500 (EST)
Message-ID: <20120301.154258.1696335721519362903.davem@davemloft.net>
References: <1330426059.2139.21.camel@megeve>
	<20120228.140558.1132853996225815681.davem@davemloft.net>
	<4F4F641E.7000501@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	eric.dumazet@gmail.com, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: javier.martinez@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4F641E.7000501@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Date: Thu, 01 Mar 2012 12:57:18 +0100

> Does this makes more sense to you?

No, creating an entire new socket family for one user doesn't make
any sense.
