From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] mlxsw: spectrum: Add support for VLAN
 offload for cls_flower
Date: Thu, 09 Mar 2017 18:36:05 -0800 (PST)
Message-ID: <20170309.183605.925403337205111122.davem@davemloft.net>
References: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdCJCgH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 21:36:07 -0500
In-Reply-To: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Mar 2017 09:25:18 +0100

> This patchset adds support to offload VLAN modify TC action and adds support
> to offload cls_flower rules that include VID and PCP matching.

Series applied, thanks Jiri.
