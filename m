From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] s390: claw network device driver
Date: Tue, 29 Mar 2005 02:44:35 -0500
Message-ID: <42490763.5010008@pobox.com>
References: <200503290533.j2T5XEYT028850@hera.kernel.org>	<4248FBFD.5000809@pobox.com>	<20050328230830.5e90396f.akpm@osdl.org>	<20050329071210.GA16409@havoc.gtf.org> <20050328232359.4f1e04b9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050328232359.4f1e04b9.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> > Was cc'ed to linux-net last Thursday, but it looks like the messages was
>> > too large and the vger server munched it.
>>
>> This also brings up a larger question... why was a completely unreviewed
>> net driver merged?
> 
> 
> Because nobody noticed that it didn't make it to the mailing list,
> obviously.

That's ducking the question.  Let me rephrase.

Why was a complete lack of response judged to be an ACK?

For new drivers, that's a -horrible- precedent.  You are quite skilled 
at poking random hackers :)  why not poke somebody to ack a new drivers? 
  It's not like this driver (or many of the other new drivers) 
desperately need to get into the kernel ASAP, so desperate that a lack 
of review was OK.

	Jeff
