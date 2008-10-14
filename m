From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUILD_FAILURE] 2.6.27-git2 - allyesconfig on powerpc
	selectsCONFIG_INTEL_IOATDMA=y
Date: Tue, 14 Oct 2008 20:58:22 +0300
Message-ID: <20081014175822.GA4710@cs181140183.pp.htv.fi>
References: <20081013101559.GA14372@linux.vnet.ibm.com> <20081013112631.GD29938@cs181140183.pp.htv.fi> <36D9DB17C6DE9E40B059440DB8D95F52066E2EAE@orsmsx418.amr.corp.intel.com> <48F391B9.1000206@myri.com> <20081013183503.GA28133@cs181140183.pp.htv.fi> <48F4627E.30300@myri.com> <36D9DB17C6DE9E40B059440DB8D95F52066E36C7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Brice Goglin <brice@myri.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org, apw@shadowen.org,
	linuxppc-dev@ozlabs.org, sam@ravnborg.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:60060 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbYJNR7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 13:59:31 -0400
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52066E36C7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 09:10:33AM -0700, Brandeburg, Jesse wrote:
> Brice Goglin wrote:
> > Adrian Bunk wrote:
> >> But considering that igb is in a similar situation it would be nice
> >> if all 3 drivers would handle it the same way.
> >> 
> > 
> > Jesse,
> > What do you think of the below patch?
> 
> Seems like a much better solution.  I can have Jeff Kirsher work on the
> equivalent patches for igb, and ixgbe today.
> 
> > I am not very familiar with Kconfig, but it seems to solve the
> > problem. 
> > If a Kconfig guru could double-check...
> 
> Yeah, please Kconfig gurus on the list have a quick look.

Brice's patch looks fine.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

