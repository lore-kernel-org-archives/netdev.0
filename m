From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/10] openvswitch: Conntrack integration
 improvements.
Date: Thu, 09 Feb 2017 23:00:03 -0500 (EST)
Message-ID: <20170209.230003.218280941905141491.davem@davemloft.net>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@ovn.org, pshelar@ovn.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdBJEAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 23:00:17 -0500
In-Reply-To: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Thu,  9 Feb 2017 11:21:51 -0800

> This series improves the conntrack integration code in the openvswitch
> module by fixing outdated comments (patch 1), bugs (patches 2, 3, and
> 7), clarifying code (patches 4, 5, and 6), improving performance
> (patch 10), and adding new features enabling better translation from
> firewall admission policy to network configuration requested by user
> communities (patches 8 and 9).
> 
> Please note that v3 of the series was Acked by Pravin, but I posted a
> v4 addressing the remaining english language and coding style issues
> posted by Joe on v2.
> 
> v4: Address remaining language and coding style issues from Joe.
> v3: Rebase to the current net-next, add the comment only changing
>     patch 1 and reshuffle some of the patches as requested by Joe.

Ok, I caught this v4 before pushing out v3 by mistake.

Series applied, th anks.
