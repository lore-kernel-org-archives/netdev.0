From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 10324] New: kernel panic ip_route_input
Date: Tue, 25 Mar 2008 16:49:09 -0700
Message-ID: <20080325164909.7f086142@speedy>
References: <bug-10324-10286@http.bugzilla.kernel.org/>
	<20080325130302.d3f6757c.akpm@linux-foundation.org>
	<20080325230945.M27660@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: "Denys" <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50645 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756490AbYCYXt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 19:49:27 -0400
In-Reply-To: <20080325230945.M27660@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Mar 2008 01:12:01 +0200
"Denys" <nuclearcat@nuclearcat.com> wrote:

> Changing from FIB_TRIE to FIB_HASH, and it is not panicing anymore. It seems
> recent patches to FIB_TRIE broke something (i have complicated setup with ifb,
> maybe it will help). If you can point me to any patch, i can reverse it and
> try again with TRIE.

Bisect?
