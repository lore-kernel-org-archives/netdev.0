From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] drivers/net Documentation/networking:
 Create directory intel_wired_lan
Date: Wed, 13 Oct 2010 22:57:37 -0700
Message-ID: <1287035857.1117.528.camel@Joe-Laptop>
References: <1286743352.11039.165.camel@Joe-Laptop>
	 <AANLkTikVKufQRuMGd=cdig7ff4k2aw9Q1FWwMz3pgon-@mail.gmail.com>
	 <1286841648.26045.17.camel@Joe-Laptop>
	 <1287008906.1117.428.camel@Joe-Laptop>
	 <1287032255.4113.14.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2962 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709Ab0JNF5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 01:57:40 -0400
In-Reply-To: <1287032255.4113.14.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-13 at 21:57 -0700, Jeff Kirsher wrote:
> On Wed, 2010-10-13 at 15:28 -0700, Joe Perches wrote:
> Sorry I am not ignoring you, I was taking a closer look at your patch.
> > What regression testing would actually be done?
> The Makefile and Kconfig needs more work.  I applied your patch and none
> of the Intel Wired drivers build.

Care to describe the Makefile/Kconfig issues you have seen?

I built it allyesconfig, defconfig, allmodconfig and allnoconfig.

Perhaps you need to use "git am foo" in a test branch instead
of "patch -p1 < foo" ?

> I am working on providing an updated RFC patch to resolve the
> Makefile/Kconfig issues I found and few other minor issues I have
> found. 

Oh good.

cheers, Joe

