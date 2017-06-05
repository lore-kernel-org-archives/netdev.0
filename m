From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] mlxsw: Minor cleanup
Date: Sun, 04 Jun 2017 23:50:07 -0400 (EDT)
Message-ID: <20170604.235007.214023992889938154.davem@davemloft.net>
References: <20170604145340.14447-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdFEDuQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 23:50:16 -0400
In-Reply-To: <20170604145340.14447-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  4 Jun 2017 16:53:37 +0200

> Fix small issues I noticed during the refactoring.
> 
> First patch adds file name comments in the header file to make it clear
> what goes where. Second patch fixes a typo and third patch simply aligns
> RIF index allocation with similar allocations in the driver.

Series applied.
