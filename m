From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] bridge: Fix kernel oops during bridge
 creation
Date: Tue, 11 Apr 2017 22:23:03 -0400 (EDT)
Message-ID: <20170411.222303.1239914373445400319.davem@davemloft.net>
References: <20170410115928.9344-1-idosch@idosch.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org, mlxsw@mellanox.com,
        peter@svinota.eu, nikolay@cumulusnetworks.com, idosch@mellanox.com
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751992AbdDLCXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 22:23:05 -0400
In-Reply-To: <20170410115928.9344-1-idosch@idosch.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: idosch@idosch.org
Date: Mon, 10 Apr 2017 14:59:26 +0300

> From: Ido Schimmel <idosch@mellanox.com>
> 
> First patch adds a missing ndo_uninit() in the bridge driver, which is a
> prerequisite for the second patch that actually fixes the oops.
> 
> Please consider both patches for 4.4.y, 4.9.y and 4.10.y

Series applied and queued up for -stable, thank you.
