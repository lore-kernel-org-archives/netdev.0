From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Wed, 19 Sep 2007 22:33:25 -0400
Message-ID: <1190255605.4818.25.camel@localhost>
References: <20070917.190133.79431533.davem@davemloft.net>
	 <1190083728.4237.59.camel@localhost> <1190208832.4259.6.camel@localhost>
	 <20070919.090937.32177545.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:33480 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbXITCd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 22:33:29 -0400
Received: by wx-out-0506.google.com with SMTP id h31so314114wxd
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 19:33:28 -0700 (PDT)
In-Reply-To: <20070919.090937.32177545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-19-09 at 09:09 -0700, David Miller wrote:

> Sure, along with a description as to why you want to make this
> change.

Will do. And if you feel that i should sit on it a little more i can do
that too. The good news is it doesnt make things any worse than they
already are and infact shows a slight improvement in a 4 cpu machine.

> I still don't understand the impetus. :)

I will like to use the effect later on to improve batching. 

cheers,
jamal

