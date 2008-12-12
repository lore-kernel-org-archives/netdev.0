From: James Morris <jmorris@namei.org>
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Sat, 13 Dec 2008 08:40:58 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812130840460.3379@tundra.namei.org>
References: <49381644.8020502@intel.com> <20081204175236.GA19808@x200.localdomain> <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil> <20081204.102138.123959105.davem@davemloft.net> <1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
 <1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil> <m1bpvrslk0.fsf@frodo.ebiederm.org> <1228486339.20274.3.camel@localhost.localdomain> <alpine.LRH.1.10.0812112139340.25553@tundra.namei.org> <20081212052420.GA14948@x200.localdomain>
 <alpine.LRH.1.10.0812122022520.32426@tundra.namei.org> <alpine.LRH.1.10.0812122028470.32426@tundra.namei.org> <m1d4fxmzss.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	Andrew Morton <akpm@linux-foundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Daniel J Walsh <dwalsh@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:4879 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753572AbYLLVtu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 16:49:50 -0500
In-Reply-To: <m1d4fxmzss.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Dec 2008, Eric W. Biederman wrote:

> James Morris <jmorris@namei.org> writes:
> 
> > On Fri, 12 Dec 2008, James Morris wrote:
> >
> >> It seems the problem is that the /proc/net mountpoint is now labeled as 
> >> proc_t.
> >
> > Actually, that's not the problem, it's the same on a normal kernel.
> 
> To confirm what you are saying.  There is something wrong with the bug fix?

There's still a problem, yes.

-- 
James Morris
<jmorris@namei.org>
