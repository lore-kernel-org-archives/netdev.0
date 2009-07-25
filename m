From: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe in
	back trace (regression)
Date: Sat, 25 Jul 2009 12:41:43 +0800
Message-ID: <43d009740907242141w1eaf3926w97f3bba411d19af7@mail.gmail.com>
References: <4A68B5DA.5000307@gmail.com> <20090725033328.GA30919@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, davem@davemloft.net,
	akpm@linux-foundation.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:51260 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbZGYEsg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 00:48:36 -0400
Received: by gxk9 with SMTP id 9so3931990gxk.13
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 21:48:35 -0700 (PDT)
In-Reply-To: <20090725033328.GA30919@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/7/25 Herbert Xu <herbert@gondor.apana.org.au>:
[...]
> Well it depends on whether he's using the kernel pppoe stack or
> doing pppoe in user-space. =C2=A0If the latter then yes those fixes

	In my Bugzilla's bug-report I mentioned pppoe's related functions in
oops-backtraces; how do you think could that really be caused by
user-space pppoe "doing"? I don't think so. I guess you missed that
point.

> may help. =C2=A0Otherwise we really need to see the backtraces.
>
	It was always clear that backtraces were welcome but I hadn't a
chance to save it yet.

--=20
End of message. Next message?
