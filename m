From: Andi Kleen <ak@suse.de>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 8 Jul 2004 18:27:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708162703.GA12934@wotan.suse.de>
References: <1525.1089275651@www62.gmx.net> <40ED748F.8000700@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael T Kerrisk <mtk-lists@gmx.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <40ED748F.8000700@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2004 at 12:21:35PM -0400, Chris Friesen wrote:
> Michael T Kerrisk wrote:
> 
> >MSG_DONTWAIT should also work with recvmsg().
> 
> Hmm...  Just tried it with a DGRAM socket, and it seems to work.  Any ideas 
> why its not in the man pages?

Nobody ever added it? Just send a patch to aeb@cwi.nl

-Andi
