From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Sun, 25 Sep 2011 21:13:17 -0400
Message-ID: <1316999597.1865.37.camel@mojatatu>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1316825745.1865.24.camel@mojatatu>
	 <1316978684.2531.7.camel@edumazet-laptop>
	 <1316999266.1865.35.camel@mojatatu>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:65195 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab1IZBNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 21:13:24 -0400
Received: by ywb5 with SMTP id 5so3911513ywb.19
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 18:13:23 -0700 (PDT)
In-Reply-To: <1316999266.1865.35.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-25 at 21:07 -0400, jamal wrote:

> In regards to the 'linux funny extension' - this was a brilliant idea
> in my opinion back then from Alexey; lots of discussions happened but
> I cant remember if it made it in some RFC or not (I will try to search
> some old archives).

Wasnt hard:
https://tools.ietf.org/id/draft-ietf-tsvwg-tcp-ecn-00.txt
It doesnt seem to have made it to RFC and i cant remember why.
[We dont wanna bring Sally out of retirement but we can ask KK if
it bugs you;->]

cheers,
jamal
