From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Finding a hidden bound TCP socket
Date: Wed, 23 Nov 2011 21:32:09 +0100
Message-ID: <1322080329.2775.8.camel@edumazet-laptop>
References: <CALmbKGV0g2nfNAghF5dGrt=TCyrms6RznOL8jSkg+gkgyfekLg@mail.gmail.com>
	 <CAFLxGvynabpEcX2RwiLxatjOEzizj95jAVY6E4D9ymDpn8s9UA@mail.gmail.com>
	 <CALmbKGVUuZs+wigpkr0WPfn2pYP=tQh5-MsYWeRxbug=HskVQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "G. D. Fuego" <gdfuego@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALmbKGVUuZs+wigpkr0WPfn2pYP=tQh5-MsYWeRxbug=HskVQQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 23 novembre 2011 =C3=A0 15:27 -0500, G. D. Fuego a =C3=A9cr=
it :
> Any comments?  The behavior seems broken.  At the very least its very
> inconsistent with other Unixes.

=46eel free to send a patch ;)

A user/process can consume all ports anyway, the 65000 port range is so
small...
