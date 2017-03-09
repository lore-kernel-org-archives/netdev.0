From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] flow dissector improvements
Date: Wed, 08 Mar 2017 23:09:25 -0800 (PST)
Message-ID: <20170308.230925.1644172913344614319.davem@davemloft.net>
References: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, hadarh@mellanox.com, e@erig.me,
        fgao@ikuai8.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdCIHJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 02:09:59 -0500
In-Reply-To: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  6 Mar 2017 16:39:50 +0100

> This patchset follows-up the discussion about future extensions of flow
> dissector and tries to address the mentioned concerns. Some parts are
> cut out into sub-functions. Also, the processing of the code (ARP, MPLS)
> is made dependent on user actually requiring the bisected values.
> This prepares the code for future extensions to bisect IPv6 ND messages,
> TCP flags, etc.

Series applied, thanks Jiri.
