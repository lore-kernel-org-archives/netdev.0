From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] include/linux/netfilter_bridge.h: header cleanup
Date: Sat, 29 Jul 2006 00:55:28 -0700
Message-ID: <20060729005528.caadc6ff.akpm@osdl.org>
References: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:41868 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932612AbWG2Hzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 03:55:35 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060729074545.GA6843@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006 11:45:45 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> Header doesn't use anything from atomic.h.


OK, but..

> It fixes headers_check warning:
> 
> include/linux/netfilter_bridge.h requires asm/atomic.h, which does not exist

asm/atomic.h _does_ exist.  What's up with that?
