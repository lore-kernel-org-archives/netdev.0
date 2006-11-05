From: Paul Moore <paul.moore@hp.com>
Subject: Re: linux-2.6.19-rc4-g10b1fbdb build #114 failed
Date: Sun, 5 Nov 2006 14:38:31 -0500
Message-ID: <200611051438.36302.paul.moore@hp.com>
References: <200611051943.27210.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:32900 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1161685AbWKETiz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 14:38:55 -0500
To: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
In-Reply-To: <200611051943.27210.toralf.foerster@gmx.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 05 November 2006 1:43 pm, Toralf F=F6rster wrote:
> Hello,
>
> the build with the attached .config failed, make ends with:
> ...
>
> : undefined reference to `cipso_v4_sock_getattr'

Hmm, that's both strange and not good :(  I'm grabbing Linus' latests b=
its and=20
I'll see what I can do.

--=20
paul moore
linux security @ hp
