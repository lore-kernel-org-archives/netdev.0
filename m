From: Alex Pankratov <ap@cipherica.com>
Subject: Re: [PATCH] more improvement to dev_alloc_name -- strnchr
Date: Mon, 19 Jan 2004 15:27:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400C67F4.2050801@cipherica.com>
References: <1074302619.40088e9bd44a6@www.geekmail.cc>	<20040119113204.5913a8d6.shemminger@osdl.org>	<20040119210605.3cea32b0.ak@suse.de>	<20040119130744.324f582b.shemminger@osdl.org> <20040119221515.74629ac4.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040119221515.74629ac4.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Andi Kleen wrote:
> 
> Not sure what it has to do with that. The #ifdef __HAVE_ARCH_* stuff 
> is that architectures with crazy enough hackers can add assembly
> optimized functions if they want. But it clearly doesn't make any sense
> with this function (in fact it doesn't make much sense with any string
> function except memset/memcpy) ... [snip]

.. as well as memchr/memrchr/memcmp and strlen. Just nitpicking :)
