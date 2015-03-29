From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 0/4] netlink: access functions for IP address
 attributes
Date: Sun, 29 Mar 2015 21:02:33 +0200
Message-ID: <1427655753.2101.0.camel@sipsolutions.net>
References: <cover.1427639592.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Chapman <jchapman@katalix.com>,
	Paul Moore <paul@paul-moore.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42481 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbbC2TCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 15:02:39 -0400
In-Reply-To: <cover.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-29 at 16:59 +0200, Jiri Benc wrote:

> The conversion is straightforward and the resulting patches are not that
> large, thus I kept all the changes in the patches that introduce the access
> functions. If anyone prefers to split the definition of access functions and
> the conversion and/or break it out by network protocols, please let me know.

Looks fine to me as far as the conversion is concerned, it's not code we
touch much so feel free to take through any tree you like.

Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes
