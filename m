From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] staging: net: core: skbuff.c: Added do-while pair for
 complex macros
Date: Thu, 26 Nov 2015 16:43:05 -0500 (EST)
Message-ID: <20151126.164305.476318553849704347.davem@davemloft.net>
References: <1448555763-5088-1-git-send-email-jitendra.khasdev@hotwaxsystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, alexander.h.duyck@redhat.com,
	linus.luessing@c0d3.bluen, hannes@stressinduktion.org,
	willemb@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jitendra.khasdev@hotwaxsystems.com
To: jkhasdev@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448555763-5088-1-git-send-email-jitendra.khasdev@hotwaxsystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jitendra Kumar Khasdev <jkhasdev@gmail.com>
Date: Thu, 26 Nov 2015 22:06:03 +0530

> This patch is to file skbuff.c that fixes up following error,
> reported by checkpatch.pl tool,
> 
> 1. ERROR: Macros with multiple statements should be enclosed
>    in a do - while loop.
> 
> Signed-off-by: Jitendra Kumar Khasdev <jkhasdev@gmail.com>

It is absolutely not appropriate to submit this to the -staging tree.
