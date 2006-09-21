From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: allow vlan interfaces to receive ToDS frames
Date: Thu, 21 Sep 2006 21:30:00 +0200
Message-ID: <20060921213000.54cb25c1@logostar.upir.cz>
References: <20060914143356.GB1962@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12211 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751484AbWIUTaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:30:18 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060914143356.GB1962@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, 14 Sep 2006 07:33:56 -0700, David Kimdon pise:
> Interfaces of type IEEE80211_IF_TYPE_VLAN need to be able to
> receive ToDS frames.

Applied to my tree. Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
