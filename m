From: Joe Perches <joe@perches.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 16:31:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1067646688.11564.189.camel@localhost.localdomain>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
	 <1067635446.11564.92.camel@localhost.localdomain>
	 <20031031132331.35a9aaca.davem@redhat.com>  <3FA2F069.4070005@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Huth <mhuth@mvista.com>
In-Reply-To: <3FA2F069.4070005@mvista.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-10-31 at 15:29, Mark Huth wrote:
> Nah, they are different algorithms, as the assembler code clearly 
> demonstrates.  The above snippet is incomplete, with the crucial 
> multiply by 2 or the shift left omitted.  The assembler code reveals 
> this crucial piece of information.

Right.  My mistake.  Clear upon explanation, thanks.
I think I misread based on expectation rather than code.
