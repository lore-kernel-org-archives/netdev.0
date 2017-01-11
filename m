From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net/sched: cls_flower: Support matching
 ARP
Date: Wed, 11 Jan 2017 11:04:40 -0500 (EST)
Message-ID: <20170111.110440.419194808990740589.davem@davemloft.net>
References: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, dinan.gunawardena@netronome.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932852AbdAKQEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:04:42 -0500
In-Reply-To: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Wed, 11 Jan 2017 14:05:41 +0100

> Add support for support matching on ARP operation, and hardware and
> protocol addresses for Ethernet hardware and IPv4 protocol addresses.
> 
> Changes since RFC:
> * None other than dropping RFC designation after positive feedback from Jiri

Series applied, thanks Simon.
