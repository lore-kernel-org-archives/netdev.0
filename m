From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 11:13:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415AFB63.7010107@us.ibm.com>
References: <1096481023.8636.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1096481023.8636.7.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> There is lots of stuff going on that has a potential to make things less
> stable. How about routing any future TCP, fib, statistics, stuff through
> Andrew's tree and not directly to Linus. That way we have some buffer
> and can stablize some more. Alternatively, Dave you could publize your
> staging area some more.

That would help us out a bit - we're testing mainline
and -mm regularly. This came up for me yesterday, too,
with Dave's tso patches (which I'm testing right now,
after getting past some hw issues). I was going to
suggest a separate bk tree or something that would
hold this stuff till it stabilized, before it needed
to go into mainline. Having that picked up by mm would
help us to increase coverage quite a bit.

thanks,
Nivedita
