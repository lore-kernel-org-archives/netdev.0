From: Patrick McHardy <kaber@trash.net>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Thu, 24 Nov 2011 08:11:56 +0100
Message-ID: <4ECDEE3C.1030306@trash.net>
References: <CA+55aFxtSgLppJQ8EbQEovdXsCNxQ1gT31FyP2cpyuvoBLajZw@mail.gmail.com> <alpine.LNX.2.01.1111232217220.27025@frira.zrqbmnf.qr> <CA+55aFyQGf4sFNOVsv4krddn3gxQ=roqVHpC98-Ynx8iBqpRaQ@mail.gmail.com> <alpine.LNX.2.01.1111232325500.27025@frira.zrqbmnf.qr> <CA+55aFxPHAf7DDD4cd3ZHNhwdbV4ijSZz83U5=5BzYqgiVKdtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxPHAf7DDD4cd3ZHNhwdbV4ijSZz83U5=5BzYqgiVKdtg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.11.2011 23:58, Linus Torvalds wrote:
> On Wed, Nov 23, 2011 at 2:32 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>>
>> Right, but how would you decide what will be enabled/disabled by
>> default? It seems unlikely you will be adding a patch (like Dave's)
>> everytime a default distro installation throws certain errors once
>> you run your own kernel configs.
> 
> I do think that "major distributions do this by default" should simply
> be the point for deciding it. Nothing more, nothing less.

Agreed, that's also the criteria we used when we introduced this option.
