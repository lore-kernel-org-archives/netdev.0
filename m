From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] ipv4: fib: FIB notifications cleanup
Date: Fri, 10 Mar 2017 09:45:47 -0800 (PST)
Message-ID: <20170310.094547.2238495287058071870.davem@davemloft.net>
References: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdCJRpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:45:50 -0500
In-Reply-To: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 10 Mar 2017 08:56:17 +0100

> Ido says:
> 
> The first patch moves the core FIB notification code to a separate file,
> so that code related to FIB rules is placed in fib_rules.c and not
> fib_trie.c. The reason for the change will become even more apparent in
> follow-up patchset where we extend the FIB rules notifications.
> 
> Second patch removes a redundant argument.

Looks good, series applied.
