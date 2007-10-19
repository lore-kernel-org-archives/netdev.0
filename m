From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: networking crash in current mainline:
 sk_filter_delayed_uncharge()
Date: Thu, 18 Oct 2007 23:48:53 -0700
Message-ID: <20071018234853.b799e58a.akpm@linux-foundation.org>
References: <20071018230948.959e89d1.akpm@linux-foundation.org>
	<20071018.231127.00953748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37822 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751242AbXJSGtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 02:49:23 -0400
In-Reply-To: <20071018.231127.00953748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 23:11:27 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 18 Oct 2007 23:09:48 -0700
> 
> > 
> > powerpc mac G5
> > config: http://userweb.kernel.org/~akpm/config-g5.txt
> > screenshot: http://userweb.kernel.org/~akpm/dsc00005.jpg
> > 
> > It does this shortly after bringing up eth0 (tg3), in dhclient.
> 
> Try this:

Now it says "login:".  Let me know if you want a photo ;)
