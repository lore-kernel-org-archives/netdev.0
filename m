From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix wrong English expression in comments
Date: Mon, 12 Jan 2009 23:44:41 -0800 (PST)
Message-ID: <20090112.234441.131571840.davem@davemloft.net>
References: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
	<496A9753.80802@cn.fujitsu.com>
	<6b1ba94c0901122336r511fa316o5f520a8d2d9d6e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizf@cn.fujitsu.com, qhfeng.kernel@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe.tian.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43296
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753904AbZAMHok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:44:40 -0500
In-Reply-To: <6b1ba94c0901122336r511fa316o5f520a8d2d9d6e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: joe tian <joe.tian.kernel@gmail.com>
Date: Tue, 13 Jan 2009 15:36:51 +0800

> 2009/1/12 Li Zefan <lizf@cn.fujitsu.com>:
> >> @@ -103,7 +103,7 @@ struct inet_bind_bucket;
> >>  struct inet_timewait_sock {
> >>       /*
> >>        * Now struct sock also uses sock_common, so please just
> >> -      * don't add nothing before this first member (__tw_common) --acme
> >> +      * don't add anything before this first member (__tw_common) --acme
> >
> > They are the same meaning...
> >
> I don't think they are the same meaning.
> I think "don't add anything" means "do add nothing" but not means "don't add
> nothing"

No offense to anyone, but the only people arguing for "correctness"
seem to be non-native speakers of English.  Is this correct? :-)

As Ben tries to explain, "don't add nothing" is a colloquialism of
English that in fact can mean "do not add"

It sounds amusing when read, and I'm not killing the character and
personality of this comment just for some language lawyering.

No way.
