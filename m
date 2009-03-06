From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [net-next PATCH 1/2] PCI: Add PCI quirk to disable L0s ASPM state for 82575 and 82598
Date: Thu, 5 Mar 2009 18:02:07 -0700
Message-ID: <20090306010207.GA829@parisc-linux.org>
References: <20090304020308.15176.40527.stgit@lost.foo-projects.org> <20090304040526.GB1884@parisc-linux.org> <20090305.163108.70528099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com,
	linux-pci@vger.kernel.org, willy@linux.intel.com,
	jbarnes@virtuousgeek.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:51711 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754629AbZCFBC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 20:02:26 -0500
Content-Disposition: inline
In-Reply-To: <20090305.163108.70528099.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2009 at 04:31:08PM -0800, David Miller wrote:
> From: Matthew Wilcox <matthew@wil.cx>
> Date: Tue, 3 Mar 2009 21:05:26 -0700
> 
> > I'm not going to ack this patch at this point, let's just give it a day.
> 
> More than a day has passed, how long are we going to let this
> patch sit and rot?
> 
> Do we have to wait until Jesse gets back?  That doesn't sound
> reasonable to me.

A lot of the discussion on this happened face-to-face; Jeff, Linus and I
were all at the same conference this week.  I have put it in a pci fixes
tree, which I now have to pull apart again because one of the earlier
patches needs to be dropped.  I'm getting on a plane tonight and flying
home, so I'll be pushing this fix to Linus tomorrow.

Sorry for not keeping you in the loop on this one.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
