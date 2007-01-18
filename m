From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 0/4] spidernet: add support for Celleb
Date: Thu, 18 Jan 2007 11:47:32 +1100
Message-ID: <1169081253.4965.35.camel@localhost.localdomain>
References: <200701171000.l0HA0jnD021501@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35362 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbXARArR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 19:47:17 -0500
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
In-Reply-To: <200701171000.l0HA0jnD021501@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 19:00 +0900, Ishizaki Kou wrote:
> Dear everyone,
> 
> This is a revised version of the patch set for spider_net driver
> that works on Toshiba Cell Refererence Set (aka Celleb).
> 
> This patch set is based on netdev-2.6.git#upstream.

Jens, can you give that a go on our blades see if it doesn't break
anything ? We are all at LCA here so it's a bit hard to test !

Cheers,
Ben.


