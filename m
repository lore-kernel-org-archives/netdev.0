From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: So you thought sis190 was evil...
Date: Mon, 01 Sep 2003 10:29:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5357BE.4060902@pobox.com>
References: <3F529E71.20402@pobox.com> <20030901091321.A4000@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20030901091321.A4000@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> 
>>It looks like the objectionable sis190 code was copied almost wholesale 
>>from r8169...   virt_to_bus, static descriptors, lack of cpu_to_leXX, 
>>and all.
> 
> 
> Are you asking for a copy from sis190 to r8169 ?


hehe :)

Actually, no.  I have docs and test hardware for RTL-8169, and it's 
basically the same as RTL-8139C+ (8139cp).

So, for r8169 I'm coming to copy over my RX and TX handling code.

	Jeff
