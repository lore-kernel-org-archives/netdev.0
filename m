From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next post Lorenzo] transp_v6.h: style neatening
Date: Sun, 02 Jun 2013 19:34:23 -0700
Message-ID: <1370226863.2096.19.camel@joe-AO722>
References: <1370049940.10556.100.camel@joe-AO722>
	 <20130601.195806.2024506377665086082.davem@davemloft.net>
	 <1370142368.2086.6.camel@joe-AO722>
	 <20130602.012918.1216932529595713857.davem@davemloft.net>
	 <1370164995.2086.30.camel@joe-AO722>
	 <CAKD1Yr0rRBWZ8WcMSo-xoG=X8kptBdhFBk36CjLX72BZkHuSvw@mail.gmail.com>
	 <1370192666.7400.16.camel@joe-AO722>
	 <CAKD1Yr3hBQWATGwqoxwdMhcrp4wSOXUzE4Kfi2XvmEFkidOJkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58982 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756538Ab3FCCeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jun 2013 22:34:31 -0400
In-Reply-To: <CAKD1Yr3hBQWATGwqoxwdMhcrp4wSOXUzE4Kfi2XvmEFkidOJkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 11:20 +0900, Lorenzo Colitti wrote:
> On Mon, Jun 3, 2013 at 2:04 AM, Joe Perches <joe@perches.com> wrote:
> >> I don't have strong feelings about indentation, but if possible I
> >> would like to avoid re-spinning this patchset more than twice over
> >> formatting changes to this file.
> >
> > You could do nothing and David could apply this if
> > he wants a more complete neatening.
> 
> Joe, thanks for saving me a respin. I'd have been happy to do it
> myself too, it's just that I'm a bit confused on what the style
> actually needs to be.

For now, it's whatever style David wants it to be.

A lot of the net/ code was written before more standardized
coding styles were generally settled upon for networking
and the older code is much less standardized.

It's going to be a tradeoff between "churn" in code that
doesn't have to change much at all and whatever patch rate
for whitespace style conformity David decides to accept.

> I take it you'd like me to make the new patch use
> this indentation?

Well, I would, but David will chime in eventually.
