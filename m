From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 01/18] d80211:  LED triggers
Date: Tue, 22 Aug 2006 09:54:02 -0700
Message-ID: <20060822165402.GI13240@instant802.com>
References: <20060821074107.648561364@sipsolutions.net> <20060821075158.728615077@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-69.dex002.intermedia.net ([64.78.20.35]:1203 "EHLO
	DHOST002-69.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751413AbWHVQyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 12:54:22 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <20060821075158.728615077@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 09:41:08AM +0200, Johannes Berg wrote:
> This patch makes d80211 export LED triggers for rx/tx and introduces
> functions to allow device drivers to query the trigger names for setting
> default triggers. It also cleans up the Makefile LED related stuff.

Is someone using these or planning on using them? I have been open to
just removing all code due to lack of active use.

-- 
Jouni Malinen                                            PGP id EFC895FA
