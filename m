From: James Ketrenos <jketreno@linux.co.intel.com>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 10 Mar 2004 17:37:16 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404FA6AC.7040009@linux.co.intel.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <404F5744.1040201@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

 > Yes, it would be good to end the cycle of re-implementing 802.11 over
 > and over again ;-)

< snip >

 > * start working on generic 802.11 stack in wireless-2.6 queue

As we're currently walking the path of implementing the same thing for the 
IPW2100 driver,  being able to re-use this code would be _very nice_.

I'd like to get WEP into IPW2100 as soon as possible, and would like to do so in 
a way that would make transitioning to a common 802.11 layer seamless (or at 
least reasonably isolated).  Any suggestions on how to best do this, or where we 
might be able to help, would be much appreciated.

I'm very interested in these discussions, so if they move to or are being 
discussed on another list (besides netdev), please let me know where.

Thanks,
James
