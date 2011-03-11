From: Dave Airlie <airlied@gmail.com>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 10:40:23 +1000
Message-ID: <AANLkTikiy+hNgG=BRWKkHEHCdvJnffWP6nhp1XxsEEO+@mail.gmail.com>
References: <20110310.153444.115930379.davem@davemloft.net>
	<AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
	<20110310.155556.48513201.davem@davemloft.net>
	<AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
	<AANLkTiktUsR1vXo84H2m_tLZRgDGee+JdvxGZjX7hYMq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiktUsR1vXo84H2m_tLZRgDGee+JdvxGZjX7hYMq@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2011 at 10:34 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Mar 10, 2011 at 4:29 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> Oh well. Water under the bridge. I think I'll try --no-ff this once,
>> despite my misgivings about the concept.
>
> Oh wow. That really does end up looking odd. I know some other git
> projects use --no-ff, but I don't think we've ever had them in the
> kernel, and I've never see the graph look like that before.
>
> But it did allow me to add an explanation for what happened, so maybe
> it's worth it.

I didn't realise we weren't meant to --no-ff, I've been lately using
--no-ff --log
so I can keep track of what I merged easier, when someone bases something on my
tree and I haven't moved it in a while.

Though I suppose author/committer info should tell me this I've found
having the logs
at least a bit useful.

Dave.
