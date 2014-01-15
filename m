From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v5 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Wed, 15 Jan 2014 15:43:31 +0100
Message-ID: <20140115144331.GF19945@order.stressinduktion.org>
References: <20140110.181030.2081631538801450145.davem@davemloft.net> <1389796619-13440-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39437 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbaAOOnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:43:32 -0500
Content-Disposition: inline
In-Reply-To: <1389796619-13440-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 03:36:57PM +0100, Thomas Haller wrote:
> v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
> v2 -> v3: reword commit messages, code comments and some refactoring.
> v3 -> v4: refactor, rename variables, add enum
> v4 -> v5: rebase, so that patch applies cleanly to current net-next/master

Huh? I thought those were already applied?

Hmm, they seem to be in no repository? I hope that no other patches are
affected, too.

Greetings,

  Hannes
