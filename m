From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 14:58:40 -0500
Message-ID: <42222670.3090002@pobox.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <200502271220.06560.Info@quantum-sci.com> <42221897.4000704@pobox.com> <200502271310.59682.Info@quantum-sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Quantum Scientific <Info@quantum-sci.com>
In-Reply-To: <200502271310.59682.Info@quantum-sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quantum Scientific wrote:
> On Sunday 27 February 2005 12:59, Jeff Garzik wrote:
> 
>>Connection tracking doesn't scale.  It's impossible to hash the entire 
>>Internet.
> 
> 
> I have read this.  
> 
> And I've seen inferences that IPV6 takes care of this problem somehow 
> automatically.  But no one seems to know how.

The solution is to not use connection tracking.

You don't want to break the end-to-end connection model that founded the 
Internet.

	Jeff
