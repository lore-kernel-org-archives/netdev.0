From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Undocumented IPv6 options
Date: Mon, 15 Oct 2007 13:45:53 +0200
Message-ID: <p73wsto38jy.fsf@bingen.suse.de>
References: <47130EB9.3090405@gmail.com>
	<20071015073903.GR6372@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Kerrisk <mtk.manpages@googlemail.com>,
	netdev <netdev@vger.kernel.org>, linux-man@vger.kernel.org,
	Andrew McDonald <andrew@mcdonald.org.uk>,
	linux-net@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:36258 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756555AbXJOLpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 07:45:55 -0400
In-Reply-To: <20071015073903.GR6372@mea-ext.zmailer.org> (Matti Aarnio's message of "Mon\, 15 Oct 2007 10\:39\:03 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matti Aarnio <matti.aarnio@zmailer.org> writes:
>
> Undocumented are also IPV6_JOIN_GROUP and IPV6_LEAVE_GROUP (RFC 2553 / 3493)

The IPv6 man page was never complete when I wrote it long ago.

This 

BUGS
        ...
        This man page is not complete.

is still true.

> It really looks like time for major overhaul of that (and related) man-pages
> is needed...

IPv6 just needs finishing.

One option actually since the RFCs document IPv6 basic and extended
API very well would be to somehow pull them in similar to the POSIX
manpages and let them speak for themselves.

I don't know if that is possible with the RFC copyrights though (?)

-Andi
