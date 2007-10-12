From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/6] sky2: status polling loop (post merge)
Date: Thu, 11 Oct 2007 18:36:05 -0700
Message-ID: <20071011183605.2973bed7@freepuppy.rosehill>
References: <20071012012124.965282742@linux-foundation.org>
	<20071011.182358.21595252.davem@davemloft.net>
	<20071011182921.1b20505c@freepuppy.rosehill>
	<20071011.183146.39159626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34337 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753895AbXJLBgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:36:55 -0400
In-Reply-To: <20071011.183146.39159626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 18:31:46 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Thu, 11 Oct 2007 18:29:21 -0700
> 
> > Handle the corner case where budget is exhausted correctly.
> > And save unnecessary read of index register.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Applied.
> 
> You can submit the rest later, I deleted them since they
> likely depend upon line offsets and other things in this
> patch.

Actually, they are exactly the same...

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
