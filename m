From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Thu, 28 Jul 2005 13:58:26 -0700 (PDT)
Message-ID: <20050728.135826.63129319.davem@davemloft.net>
References: <42E8FF24.9070009@cosmosbay.com>
	<20050728.123922.126777020.davem@davemloft.net>
	<42E94680.8060309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42E94680.8060309@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 28 Jul 2005 22:56:32 +0200

> But in case of DDOS, prefetches are a win.

Numbers please, I'm simply curious.
