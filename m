From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 1/2] netfilter_queue: enable UID/GID socket info
 retrieval
Date: Mon, 23 Dec 2013 15:21:18 +0100
Message-ID: <20131223142118.GA4803@localhost>
References: <1387556934-7372-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387556934-7372-2-git-send-email-valentina.giusti@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jpa@google.com, fw@strnel.de, daniel.wagner@bmw-carit.de
To: valentina.giusti@bmw-carit.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51083 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757272Ab3LWOV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 09:21:28 -0500
Content-Disposition: inline
In-Reply-To: <1387556934-7372-2-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 05:28:53PM +0100, valentina.giusti@bmw-carit.de wrote:
> From: Valentina Giusti <valentina.giusti@bmw-carit.de>
> 
> Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp: ipv4:
> Add udp early demux) it is now possible to parse UID and GID socket info
> also for incoming TCP and UDP connections. Having this info available, it
> is convenient to let NFQUEUE parse it in order to improve and refine the
> traffic analysis in userspace.

Applied the kernel patch, wait for a new patch for libnetfilter_queue. Thanks.
