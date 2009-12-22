From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 14839] New: Trying to use a TUN device fir
 IPv6 traffic, cannot set destination address.
Date: Tue, 22 Dec 2009 15:23:26 -0800
Message-ID: <20091222152326.457605b5@nehalam>
References: <bug-14839-10286@http.bugzilla.kernel.org/>
	<20091222151238.e7e44e36.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Maxim Krasnyansky <maxk@qualcomm.com>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mcisho@yahoo.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32815 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbZLVXXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2009 18:23:42 -0500
In-Reply-To: <20091222151238.e7e44e36.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2009 15:12:38 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > 
> > BTW, ifconfig cannot add an IPv6 destination address either, the code has a
> > comment saying that the support needs to be written.

Use iproute2 utilities. ifconfig is considered deprecated legacy interface,
especially for IPV6.



-- 
