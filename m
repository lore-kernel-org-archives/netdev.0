From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: missing dir in and dir fwd policy on 2.6.23
Date: Wed, 19 Dec 2007 12:01:24 +0100
Message-ID: <BAY103-DAV11DB3994E500651501D08B25C0@phx.gbl>
References: <E1J4sxK-0001st-00@gondolin.me.apana.org.au>
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s17.bay0.hotmail.com ([65.54.246.89]:55115 "EHLO
	bay0-omc1-s17.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751677AbXLSLDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 06:03:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> Marco Berizzi <pupilla@hotmail.com> wrote:
> > Hello everybody.
> > I'm experimenting a pretty strange ipsec problem with 2.6.23.x
> > and openswan 2.4.11
> > Here is the output from 'ip -s x p':
>
> It's a bug in openswan but I haven't had the time to track it
> down yet.

Is this bug recently introduced? I'm using this
config since 2.6.16/openswan 2.4.4 (two years).
I haven't never noticed: now I must restart openswan
once a day :-(

> Anyway, the kernel is not involved since the management
> of policies is entirely up to the user-space Key Manager.


