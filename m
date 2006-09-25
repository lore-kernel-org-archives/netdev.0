From: jamal <hadi@cyberus.ca>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Mon, 25 Sep 2006 08:55:36 -0400
Message-ID: <1159188936.5301.72.camel@jzny2>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei>
	 <E1GRdnS-0003kd-00@gondolin.me.apana.org.au>
	 <20060925103836.GA13966@2ka.mipt.ru>
	 <20060925112754.GA18228@gondor.apana.org.au>
	 <20060925120519.GA19010@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@namei.org>, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:57478 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751138AbWIYMzo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 08:55:44 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GRpzu-0000Rh-Rr
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 08:55:46 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060925120519.GA19010@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-25-09 at 16:05 +0400, Evgeniy Polyakov wrote:
> On Mon, Sep 25, 2006 at 09:27:54PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:

> > Please run ip x p once every second and the post what it shows
> > before, during and after the period when unecrypted packets show
> > up on the wire.
> > 
> > You only have to do it on the 79 machine since it's the one sending
> > unencrypted data.
> 
> Attached three files - before, while and after connection establishment.

I think a -s option would have been helpful 
i.e ip -s x p and also if the script printed output of date command
(to compare against when last use was - if i read correctly what Herbert
was getting at)
 
cheers,
jamal

