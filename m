From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Adding Agile-SD TCP module and modifying Kconfig and
 Makefile
Date: Tue, 01 Aug 2017 22:47:26 -0700 (PDT)
Message-ID: <20170801.224726.2084508191542326424.davem@davemloft.net>
References: <stephen@networkplumber.org>
        <20170802043701.13507-1-mohamed.asnd@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
        linux-kernel@vger.kernel.org, mohamed.a.alrshah@ieee.org
To: mohamed.asnd@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802043701.13507-1-mohamed.asnd@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: mohamedalrshah <mohamed.asnd@gmail.com>
Date: Wed,  2 Aug 2017 12:37:01 +0800

> +//#define NS_PROTOCOL "tcp_agilesd.c"
> +//#include "../ns-linux-c.h"
> +//#include "../ns-linux-util.h"
> +//#include <math.h>

There is no way this submission will be considered seriously with all of
this cruft in it.

Your new module needs significant cleanups.
