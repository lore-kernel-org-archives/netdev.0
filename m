From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: remove initialization of unused xr structure
 members
Date: Wed, 18 Oct 2006 17:55:25 +0200
Message-ID: <20061018175525.2f946baa@griffin.suse.cz>
References: <20061013193457.GA24280@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:645 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161177AbWJRPz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:55:27 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061013193457.GA24280@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Oct 2006 12:34:57 -0700, David Kimdon wrote:
> The structure member xr_end was removed from d80211.h.

John, please apply this after you pull from my tree (perhaps with a
rt2x00 prefix in the subject instead of d80211?).

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
