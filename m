From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 3/3] d80211: silence sparse warning: bad constant
 expression
Date: Wed, 18 Oct 2006 17:40:38 +0200
Message-ID: <20061018174038.32530e64@griffin.suse.cz>
References: <20061009201102.GA10661@devicescape.com>
	<20061018155607.2320a5fa@griffin.suse.cz>
	<20061018151227.GA9777@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43651 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161037AbWJRPkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:40:43 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061018151227.GA9777@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006 08:12:27 -0700, David Kimdon wrote:
> I actually think the code reads slightly cleaner using num_algs, but
> don't have a strong preference.  I'd be happy to make the change if
> removing num_algs is preferred.

Don't know. But nobody except me objected for more than a week so I've
applied the patch to my tree.

I've also applied the following patches from you:
d80211: use FCS_LEN instead of hardcoded number.
d80211: remove unused Super AG definitions, purge comment (the second
version of the patch)

Thanks for the patches,

 Jiri

-- 
Jiri Benc
SUSE Labs
