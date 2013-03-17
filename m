From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Sun, 17 Mar 2013 12:59:21 -0400 (EDT)
Message-ID: <20130317.125921.1997502137415390783.davem@davemloft.net>
References: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504Ab3CQQ7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:59:23 -0400
In-Reply-To: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 15 Mar 2013 10:38:46 -0700

> A couple of minor enhancements for net-next/3.10.  The largest is an
> extension to allow variable length metadata to be passed to userspace
> with packets.
> 
> There is a merge conflict in net/openvswitch/vport-internal_dev.c:
> A existing commit modifies internal_dev_mac_addr() and a new commit
> deletes it.  The new one is correct, so you can just remove that function.

Pulled, thanks Jesse.

Thanks, in particular, for the heads up about the merge conflict.
