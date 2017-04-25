From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] l2tp: add informations about l2tpeth
 interfaces in /sys
Date: Tue, 25 Apr 2017 11:42:25 -0400 (EDT)
Message-ID: <20170425.114225.1596423782645691924.davem@davemloft.net>
References: <cover.1493035407.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970639AbdDYPma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:42:30 -0400
In-Reply-To: <cover.1493035407.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 24 Apr 2017 14:16:04 +0200

> Patch #1 lets userspace retrieve the naming scheme of an l2tpeth
> interface, using /sys/class/net/<iface>/name_assign_type.
> 
> Patch #2 adds the DEVTYPE field in /sys/class/net/<iface>/uevent so
> that userspace can reliably know if a device is an l2tpeth interface.

Looks great, series applied, thanks!
