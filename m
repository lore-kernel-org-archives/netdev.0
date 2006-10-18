From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [take1 0/5] d80211 patches
Date: Wed, 18 Oct 2006 10:20:09 -0700
Message-ID: <20061018172009.GA25808@devicescape.com>
References: <20061017171713.GA13669@devicescape.com> <20061018180131.556fe5bc@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:3744 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1422711AbWJRRUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 13:20:17 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061018180131.556fe5bc@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 06:01:31PM +0200, Jiri Benc wrote:
> On Tue, 17 Oct 2006 10:17:13 -0700, David Kimdon wrote:
> > Continue d80211 bitfield removal.  In general, compilers have
> > difficulty generating efficient code for bitfields.  This patchset
> > removes all bitfields from include/net/d80211.h.
> 
> Thanks for the patches! At first I intended to ask you to split d80211
> and drivers parts of the patches, but your way is better I think - it
> doesn't break git-bisect.
> 
> John, if you agree with these patches, could you apply them after you
> pull from my tree?

hold that thought, I missed updating rt73usb.c and rt2500usb.c.  New
patchset on its way.



> 
> Thanks,
> 
>  Jiri
> 
> -- 
> Jiri Benc
> SUSE Labs
