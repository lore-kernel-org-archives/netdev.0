From: jamal <hadi@cyberus.ca>
Subject: Re: take 2 WAS (RE: [RFC] make qdisc_restart more readable
Date: Sat, 12 May 2007 07:58:29 -0400
Message-ID: <1178971110.4061.1.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost>  <20070512094629.GJ521@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:10070 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068AbXELL6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 07:58:37 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1136675wxd
        for <netdev@vger.kernel.org>; Sat, 12 May 2007 04:58:36 -0700 (PDT)
In-Reply-To: <20070512094629.GJ521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-12-05 at 11:46 +0200, Thomas Graf wrote:

> > +	struct sk_buff *skb = NULL;
> > +
> > +	if (skb = dev->gso_skb) 
> 
> This must have caused a warning 

Possibly (dont recall) - i will move the assignment to the first line.

> and you probably want to inline this function.

will do.

Thanks Thomas.

cheers,
jamal

