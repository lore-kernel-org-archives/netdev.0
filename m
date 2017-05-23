From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] add tcp flags match support to flower and
 offload it
Date: Tue, 23 May 2017 11:40:27 -0400 (EDT)
Message-ID: <20170523.114027.525495248857730645.davem@davemloft.net>
References: <20170523143110.5006-1-jiri@resnulli.us>
        <20170523151120.GH1829@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36394 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764591AbdEWPk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:40:28 -0400
In-Reply-To: <20170523151120.GH1829@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 May 2017 17:11:20 +0200

> Tue, May 23, 2017 at 04:31:05PM CEST, jiri@resnulli.us wrote:
>>From: Jiri Pirko <jiri@mellanox.com>
>>
>>This patch adds support to dissect tcp flags, match on them using
>>flower classifier and offload such rules to mlxsw Spectrum devices.
> 
> I shifted the git format patch one commit. Will send v2. Sorry.

Ok.
