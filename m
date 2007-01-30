From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Hidden SSID's
Date: Mon, 29 Jan 2007 19:09:11 -0800
Message-ID: <20070130030911.GA6637@jm.kir.nu>
References: <45BACB71.2080107@lwfinger.net> <1169899689.25670.3.camel@localhost.localdomain> <1170019717.30318.0.camel@johannes.berg> <1170075611.2895.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:56990 "EHLO
	mail2.genealogia.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933015AbXA3DiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 22:38:23 -0500
Content-Disposition: inline
In-Reply-To: <1170075611.2895.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 08:00:11AM -0500, Dan Williams wrote:

> Well, there's no way a userspace program could depend on all hidden SSID
> APs having the <hidden> tag, since if you stick in another,
> non-ieee80211-stack card it won't be like that.  So I don't think we
> should care about <hidden> in d80211, but I don't think we can remove it
> from ieee80211 either.

Use of '<hidden>' is just not acceptable. IMHO, it should be removed
from everywhere, including net/ieee80211. The sooner this is done, the
better.

-- 
Jouni Malinen                                            PGP id EFC895FA
