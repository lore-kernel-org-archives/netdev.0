From: "Michael Marineau" <mike@marineau.org>
Subject: Re: [PATCH] fix for initial link state in 2.6.28
Date: Sun, 4 Jan 2009 21:11:10 -0500
Message-ID: <c0526ddf0901041811v11015db7oa080f5b1dfd3db6f@mail.gmail.com>
References: <c0526ddf0901011512t258978e9n2c9ecf7488a4a35f@mail.gmail.com>
	 <20090104.171839.14814429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:63989 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbZAECLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 21:11:13 -0500
Received: by rv-out-0506.google.com with SMTP id k40so6637287rvb.1
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2009 18:11:11 -0800 (PST)
In-Reply-To: <20090104.171839.14814429.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 4, 2009 at 8:18 PM, David Miller <davem@davemloft.net> wrote:
>
> I find it mysterious how someone can write such an excellent
> patch and such a well written commit message, then in the
> end not give a proper signoff for their changes :-/

Being completely unfamiliar with network drivers I was a bit fried
after tracing though enough code to finally understand what was going
on so it slipped my mind. :-)

>
> Applied, and queued up for -stable, but please provide proper
> signoffs in the future.

Noted. Thanks for queuing it up!
-- 
Michael Marineau
mike@marineau.org
