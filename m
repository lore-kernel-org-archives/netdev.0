From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] ipv4: fix various issues reported by sparse
Date: Fri, 08 Jan 2016 21:31:11 -0500 (EST)
Message-ID: <20160108.213111.1192941628324333991.davem@davemloft.net>
References: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbcAICbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 21:31:14 -0500
In-Reply-To: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Wed,  6 Jan 2016 17:22:44 -0500

> This trivial patch series addresses a number of endianness- and
> lock-related issues reported by sparse.

Series applied to net-next, thanks.
