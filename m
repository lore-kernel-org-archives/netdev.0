From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] mlxsw: Remove compatibility with old
 firmware
Date: Thu, 08 Jun 2017 14:34:20 -0400 (EDT)
Message-ID: <20170608.143420.1815265768388352351.davem@davemloft.net>
References: <20170608064745.4900-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHSeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:34:22 -0400
In-Reply-To: <20170608064745.4900-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  8 Jun 2017 08:47:42 +0200

> Up until recently we couldn't enforce a minimal firmware version, which
> forced us to be compatible with old firmware versions. This patchset
> removes this code and simplifies the driver.

Series applied, thanks Jiri.
