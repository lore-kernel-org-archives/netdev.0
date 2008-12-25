From: Michel Lespinasse <walken@zoy.org>
Subject: Re: [Bugme-new] [Bug 12282] New: Network data corruption on eee 1000
Date: Wed, 24 Dec 2008 20:19:43 -0800
Message-ID: <20081225041943.GA19924@zoy.org>
References: <bug-12282-10286@http.bugzilla.kernel.org/> <20081223232035.5a5caea9.akpm@linux-foundation.org> <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jie Yang <jie.yang@atheros.com>
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:51032 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbYLYETo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 23:19:44 -0500
Content-Disposition: inline
In-Reply-To: <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 07:32:36AM -0600, J. K. Cliburn wrote:
> Do things improve if you turn off TSO in the atl1e driver?
> 
> ethtool -K eth0 tso off

I'm currently away in vacation but I should be able to test this next week.

I will even try with both memory sticks, as the 1GB one seemed to give
more issues when using the wired network (but still worked fine when
just using the cpu).

Merry Christmas everyone ! :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
