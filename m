From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] s390: claw network device driver
Date: Tue, 29 Mar 2005 15:05:08 -0500
Message-ID: <4249B4F4.4050205@pobox.com>
References: <OF6B8E4881.48C8D8FB-ON41256FD3.0029171C-41256FD3.002ADBAE@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, Frank Pavlic <PAVLIC@de.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
In-Reply-To: <OF6B8E4881.48C8D8FB-ON41256FD3.0029171C-41256FD3.002ADBAE@de.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Martin Schwidefsky wrote:
> Hi Jeff,
> 
> 
>>>Was cc'ed to linux-net last Thursday, but it looks like the messages was
>>>too large and the vger server munched it.
>>
>>As mentioned in the email, you want netdev, not linux-net...
> 
> 
> we are currently thinking about changing the sign-off chain for the s390
> network patches. Dave suggested that they should go through your hands.
> If that is ok with you the new sign-off chain would be Frank Pavlic,
> Jeff Garzik, Bitkeeper. This would solve two problems:
> 1) Frank would create the patches and since he knows much more about
>    linux networking then I do, hopefully the patches and the descriptions
>    will improve (and you can probably teach him to send the patches to
>    netdev instead of linux-net).
> 2) The patches won't just slip in anymore but get a real review.

That's OK with me.  As an example, on the MIPS side of things, Ralf 
sends most MIPS stuff straight to Linus, but I queue all his 
drivers/net/* patches into my queue, and that gets submitted separately 
(though just as rapidly) upstream with other net driver changes.

I certainly do recognize that qeth, in particular, is a network driver 
unlike all others in the kernel ;-)

	Jeff
