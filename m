From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
	delayed_work
Date: Sat, 3 May 2008 23:31:52 +0800
Message-ID: <20080503153151.GG3986@hack>
References: <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain> <20080501011123.GA4060@gondor.apana.org.au> <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain> <20080502.165455.24687234.davem@davemloft.net> <20080503144647.GF3986@hack> <20080503150606.GA26898@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: WANG Cong <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:19968 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756828AbYECP1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 11:27:55 -0400
Received: by rv-out-0506.google.com with SMTP id l9so469562rvb.1
        for <netdev@vger.kernel.org>; Sat, 03 May 2008 08:27:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080503150606.GA26898@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 03, 2008 at 11:06:06PM +0800, Herbert Xu wrote:
>On Sat, May 03, 2008 at 10:46:49PM +0800, WANG Cong wrote:
>> 
>> I will try if I can set up one, then test it.
>
>I'll throw them into my test systems here and see if they break.
>

Oh, thanks a lot! ;-)
