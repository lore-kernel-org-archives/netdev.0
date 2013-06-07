From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vlan: minor: remove unused
 HAVE_VLAN_PUT_TAG
Date: Fri, 07 Jun 2013 14:39:33 -0700 (PDT)
Message-ID: <20130607.143933.910065548682410891.davem@davemloft.net>
References: <1370563711-19636-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab3FGVje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 17:39:34 -0400
In-Reply-To: <1370563711-19636-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  7 Jun 2013 02:08:31 +0200

> Remove the definition of HAVE_VLAN_PUT_TAG since it's not
> used or exported anywhere.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
