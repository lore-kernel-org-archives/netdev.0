From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net] ipv6: don't install anycast address for /128 addresses on routers
Date: Mon, 6 Jan 2014 10:06:39 -0800 (PST)
Message-ID: <1389031599.74859.YahooMailBasic@web125503.mail.ne1.yahoo.com>
References: <20140106165314.GC10204@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thaller@redhat.com, jiri@resnulli.us
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm45.bullet.mail.ne1.yahoo.com ([98.138.120.52]:43524 "HELO
	nm45.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755608AbaAFSJX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 13:09:23 -0500
In-Reply-To: <20140106165314.GC10204@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

> It does not make sense to create an anycast address for an /128-prefi=
x.
> Suppress it.

Exact !

BR,
=46ran=E7ois-Xavier
