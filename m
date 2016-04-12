From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP reaching to maximum throughput after a long time
Date: Tue, 12 Apr 2016 13:29:59 -0700
Message-ID: <1460492999.6473.599.camel@edumazet-glaptop3.roam.corp.google.com>
References: <AE1C82FB3D0EC64DB1F752C81CBD110139100057@DFRE01.ent.ti.com>
	 <1460472764.6473.589.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570D0E94.3080006@candelatech.com>
	 <AE1C82FB3D0EC64DB1F752C81CBD110139101889@DFRE01.ent.ti.com>
	 <570D566B.8050302@candelatech.com>
	 <1460492253.6473.596.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570D5944.5070100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Machani, Yaniv" <yanivma@ti.com>, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	open list <linux-kernel@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570D5944.5070100@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-04-12 at 13:23 -0700, Ben Greear wrote:

> It worked well enough for years that I didn't even know other algorithms were
> available.  It was broken around 4.0 time, and I reported it to the list,
> and no one seemed to really care enough to do anything about it.  I changed
> to reno and ignored the problem as well.
> 
> It is trivially easy to see the regression when using ath10k NIC, and from this email
> thread, I guess other NICs have similar issues.

Since it is so trivial, why don't you start a bisection ?

I asked a capture, I did not say ' switch to Reno or whatever ', right ?

Guessing is nice, but investigating and fixing is better.

Do not assume that nothing can be done, please ?

Thanks.
