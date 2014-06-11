From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Add VF link state control policy
Date: Wed, 11 Jun 2014 15:59:06 -0700 (PDT)
Message-ID: <20140611.155906.1312485071758432085.davem@davemloft.net>
References: <74ee0f0299e2043de14be353dd7d34fe07ecdf92.1402497459.git.dledford@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ronye@mellanox.com, ogerlitz@mellanox.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaFKW7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:59:08 -0400
In-Reply-To: <74ee0f0299e2043de14be353dd7d34fe07ecdf92.1402497459.git.dledford@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Wed, 11 Jun 2014 10:38:03 -0400

> Commit 1d8faf48c7 (net/core: Add VF link state control) added VF link state
> control to the netlink VF nested structure, but failed to add a proper entry
> for the new structure into the VF policy table.  Add the missing entry so
> the table and the actual data copied into the netlink nested struct are in
> sync.
> 
> Signed-off-by: Doug Ledford <dledford@redhat.com>

Applied, thanks.
