From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/6] sky2: status polling loop
Date: Thu, 11 Oct 2007 18:25:40 -0700
Message-ID: <20071011182540.06178cbc@freepuppy.rosehill>
References: <20071012011951.575936605@linux-foundation.org>
	<20071012012124.965282742@linux-foundation.org>
	<20071011.182358.21595252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44633 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753867AbXJLBZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:25:45 -0400
In-Reply-To: <20071011.182358.21595252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 18:23:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 11 Oct 2007 18:19:52 -0700
> 
> > Handle the corner case where budget is exhausted correctly.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Doesn't apply, I checked in my fixed version of your original patch
> already.
> 
> You had to have some idea I would apply that fix, so this patch series
> seems a bit premature since it's almost guarenteed to not apply any
> more.

I like to test my signed patches before applying... And if possible
send them out from the kernel running the actual code.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
