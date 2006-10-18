From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [take1 0/5] d80211 patches
Date: Wed, 18 Oct 2006 18:01:31 +0200
Message-ID: <20061018180131.556fe5bc@griffin.suse.cz>
References: <20061017171713.GA13669@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:34181 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161183AbWJRQBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 12:01:34 -0400
To: David Kimdon <david.kimdon@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061017171713.GA13669@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Oct 2006 10:17:13 -0700, David Kimdon wrote:
> Continue d80211 bitfield removal.  In general, compilers have
> difficulty generating efficient code for bitfields.  This patchset
> removes all bitfields from include/net/d80211.h.

Thanks for the patches! At first I intended to ask you to split d80211
and drivers parts of the patches, but your way is better I think - it
doesn't break git-bisect.

John, if you agree with these patches, could you apply them after you
pull from my tree?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
