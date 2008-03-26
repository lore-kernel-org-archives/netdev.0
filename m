From: "Denys" <nuclearcat@nuclearcat.com>
Subject: Re: [Bugme-new] [Bug 10324] New: kernel panic ip_route_input
Date: Wed, 26 Mar 2008 10:20:14 +0200
Message-ID: <20080326081940.M12656@nuclearcat.com>
References: <bug-10324-10286@http.bugzilla.kernel.org/> <20080325130302.d3f6757c.akpm@linux-foundation.org> <20080325230945.M27660@nuclearcat.com> <20080325164909.7f086142@speedy>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:44234 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbYCZIUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 04:20:24 -0400
In-Reply-To: <20080325164909.7f086142@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have to wait when power switch will be installed in that location then.


On Tue, 25 Mar 2008 16:49:09 -0700, Stephen Hemminger wrote
> On Wed, 26 Mar 2008 01:12:01 +0200
> "Denys" <nuclearcat@nuclearcat.com> wrote:
> 
> > Changing from FIB_TRIE to FIB_HASH, and it is not panicing anymore. It 
seems
> > recent patches to FIB_TRIE broke something (i have complicated setup with 
ifb,
> > maybe it will help). If you can point me to any patch, i can reverse it 
and
> > try again with TRIE.
> 
> Bisect?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

