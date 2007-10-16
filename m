From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
Date: Tue, 16 Oct 2007 10:29:16 -0400
Message-ID: <1192544956.4480.136.camel@localhost>
References: <1192537921.4480.80.camel@localhost>
	 <4714B445.1020900@trash.net> <1192540951.4480.108.camel@localhost>
	 <20071016140619.GA11763@gondor.apana.org.au>  <4714C65C.8070208@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:61331 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932588AbXJPO3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:29:36 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2399874wah
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 07:29:35 -0700 (PDT)
In-Reply-To: <4714C65C.8070208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-16-10 at 16:10 +0200, Patrick McHardy wrote:
> Herbert Xu wrote:
> > On Tue, Oct 16, 2007 at 09:22:31AM -0400, jamal wrote:
> >> Does the copying of tc_verd in __copy_skb_header() not cover that?
> > 
> > Yep, I'm pretty sure it does.
> > 
> > In fact this patch completely resolves my concerns about tc_verd.
> 
> 
> Indeed, I was looking at the wrong tree :)

Ok, thanks guys.

cheers,
jamal

