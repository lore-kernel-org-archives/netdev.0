From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 09 Apr 2013 13:09:10 -0400 (EDT)
Message-ID: <20130409.130910.1785959090953646981.davem@davemloft.net>
References: <1365521576.3887.147.camel@edumazet-glaptop>
	<20130409.125635.1837917915399498838.davem@davemloft.net>
	<1392983.dvWWkBd8H0@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, casey@schaufler-ca.com,
	netdev@vger.kernel.org, mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: pmoore@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1392983.dvWWkBd8H0@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Tue, 09 Apr 2013 13:00:06 -0400

> On Tuesday, April 09, 2013 12:56:35 PM David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 09 Apr 2013 08:32:56 -0700
>> 
>> > It looks like _I_ have to do your work. Sorry, I have no more time to
>> > spend on this topic. You'll have to convince David, not me.
>> 
>> I already have no interest in considering these changes seriously,
>> and I've already asked Paul multiple times to drop this idea.
> 
> If we address all of your technical concerns, why are you not interested in 
> allowing a security blob in the sk_buff?

If you have a patch that removes space, rather than adds space, to sk_buff,
then we can talk.

Otherwise, please don't waste our time, because I'm not adding anything to
sk_buff for LSM's sake.
