From: Arthur Jones <ajones@riverbed.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 3/3] e1000e: add support for new
	82574L part
Date: Wed, 20 Aug 2008 07:13:16 -0700
Message-ID: <20080820141316.GA13160@ajones-laptop.nbttech.com>
References: <20080814003759.17449.58830.stgit@jtkirshe-mobile.jf.intel.com> <20080818160040.GA17369@ajones-laptop.nbttech.com> <9929d2390808181253i55f5a4d0pae07e4a23eaba7d@mail.gmail.com> <20080819142410.GA7100@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:58001 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbYHTONT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 10:13:19 -0400
Content-Disposition: inline
In-Reply-To: <20080819142410.GA7100@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff, ...

On Tue, Aug 19, 2008 at 07:24:10AM -0700, Arthur Jones wrote:
> [...]
> > Jesse is expecting to get you a patch today to test which should
> > resolve the issue.
> 
> Yesterday I received from Intel an upgrade from pre-production
> (v0.5) 82574 firmware to production (v1.0) firmware and tools to
> install it.  With the upgrade the problem no longer appears to be
> reproducible.

Not so fast...  The problem is still there with the
new firmware, it just takes 2.5 days rather than 3-4
hours to hit.  It looks like I'll need that patch
after all...

Arthur
