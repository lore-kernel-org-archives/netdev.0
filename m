From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 14:58:25 -0800
Message-ID: <CA+55aFxPHAf7DDD4cd3ZHNhwdbV4ijSZz83U5=5BzYqgiVKdtg@mail.gmail.com>
References: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com>
 <alpine.LNX.2.01.1111232217220.27025@frira.zrqbmnf.qr> <CA+55aFyQGf4sFNOVsv4krddn3gxQ=roqVHpC98-Ynx8iBqpRaQ@mail.gmail.com>
 <alpine.LNX.2.01.1111232325500.27025@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1111232325500.27025@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 2:32 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>
> Right, but how would you decide what will be enabled/disabled by
> default? It seems unlikely you will be adding a patch (like Dave's)
> everytime a default distro installation throws certain errors once
> you run your own kernel configs.

I do think that "major distributions do this by default" should simply
be the point for deciding it. Nothing more, nothing less.

                      Linus
