From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (0/23) sk98 driver fixes and enhancements
Date: Thu, 11 Nov 2004 16:27:58 -0800
Message-ID: <20041111162758.4f38f104@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111161124.34ccb1e6@zqx3.pdx.osdl.net>
	<41940106.7030207@designassembly.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Heyse <mhk@designassembly.de>
In-Reply-To: <41940106.7030207@designassembly.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Nov 2004 01:17:10 +0100
Michael Heyse <mhk@designassembly.de> wrote:

> Stephen Hemminger wrote:
> > This is the first set of patches to merge some of the new SysKonnect
> > code with existing 2.6 driver and fix several bugs. 
> 
> So I was wrong and it did *not* take very long ;-)
> Thanks!
> 
> Michael

Still missing stuff from the SysKonnect version:
	* Yukon2 support because existing SysKonnect code is too ugly
	as it is. Next week I should have a de-mucked version.  
	* NAPI code in their version is broken under stress and needs work.
