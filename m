From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [RFC] tcp: Add (limited) SYNACK payload support
Date: Thu, 14 Aug 2008 15:01:52 -0700
Message-ID: <396556a20808141501q7c32620rdccc2d0e81578854@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe069070@europa>
	 <20080813.210251.47504019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:38428 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbYHNWBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 18:01:53 -0400
Received: by rv-out-0506.google.com with SMTP id k40so620363rvb.1
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 15:01:53 -0700 (PDT)
In-Reply-To: <20080813.210251.47504019.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 9:02 PM, David Miller <davem@davemloft.net> wrote:
> This looks mostly fine to me.  I would even advocate not using a config
> option for this.

Thanks David. I'm still in discussions with the IETF on this one, I
might resubmit a shaved down version of this at some point in the
future.


Cheers

AGL


-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
