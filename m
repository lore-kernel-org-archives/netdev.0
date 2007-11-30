From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4 net-2.6.15][UNIX] Make unix sysctls per-namespace
Date: Fri, 30 Nov 2007 15:23:44 -0700
Message-ID: <m1tzn38j9r.fsf@ebiederm.dsl.xmission.com>
References: <47503919.8060103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:52826 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbXK3WZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 17:25:48 -0500
In-Reply-To: <47503919.8060103@openvz.org> (Pavel Emelyanov's message of "Fri,
	30 Nov 2007 19:23:53 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

> Hi, Herbert, guys.
>
> Since you have accepted some net-namespaces-related work
> from Eric (sysctl namespaces), I hope, that you can pay 
> some attention to further work in this direction.
>
> This set makes the unix-sockets sysctls (currently this
> includes the sys/net/unix/max_dgram_qlen only) per net
> namespace.
>
> I splitted it into four patches, to make the review simpler.
> Hope that this split will help.
>
> This set resembles the one Eric has in his netns tree, but
> differs in some (maybe minor) ways.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Looks sane skimming through the patches.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

