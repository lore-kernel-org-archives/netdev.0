From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: sctp: convert sctp_checksum_disable
 module param into sctp sysctl
Date: Fri, 09 Aug 2013 13:10:08 -0700 (PDT)
Message-ID: <20130809.131008.773918164482459670.davem@davemloft.net>
References: <1375816693-7697-1-git-send-email-dborkman@redhat.com>
	<20130809.113320.681399334989952629.davem@davemloft.net>
	<52053A00.80808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030920Ab3HIUKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 16:10:11 -0400
In-Reply-To: <52053A00.80808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri, 09 Aug 2013 14:50:40 -0400

> Please revert this.  This isn't a knob that that should be
> so freely exposed.  I thought my response to Daniel made
> that clear.

Done, sorry about that.
