From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 6/7] d80211: fix invalid check for sub interface type AP
Date: Thu, 7 Dec 2006 13:47:19 +0100
Message-ID: <20061207134719.524d0819@griffin.suse.cz>
References: <20061207004238.540749000@devicescape.com>
	<20061207004532.GF16252@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:59346 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1032149AbWLGMrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 07:47:07 -0500
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061207004532.GF16252@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patches 1 to 6 have been applied to my tree.

Thanks,

 Jiri

On Wed, 6 Dec 2006 16:45:32 -0800, David Kimdon wrote:
> We should be checking the type member, not the raw pointer.
> 
> Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

-- 
Jiri Benc
SUSE Labs
