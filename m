From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/10] openvswitch: Conntrack integration
 improvements.
Date: Thu, 09 Feb 2017 22:52:26 -0500 (EST)
Message-ID: <20170209.225226.579486809593878179.davem@davemloft.net>
References: <1486603837-7202-1-git-send-email-jarno@ovn.org>
        <CAOrHB_CiVOAQzBpFccZrnuS2Aa2YpdjnGeoivahy+MCdjuw1cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarno@ovn.org, netdev@vger.kernel.org, joe@ovn.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdBJDwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 22:52:36 -0500
In-Reply-To: <CAOrHB_CiVOAQzBpFccZrnuS2Aa2YpdjnGeoivahy+MCdjuw1cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@ovn.org>
Date: Thu, 9 Feb 2017 08:44:55 -0800

> On Wed, Feb 8, 2017 at 5:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> This series improves the conntrack integration code in the openvswitch
>> module by fixing outdated comments (patch 1), bugs (patches 2, 3, and
>> 7), clarifying code (patches 4, 5, and 6), improving performance
>> (patch 10), and adding new features enabling better translation from
>> firewall admission policy to network configuration requested by user
>> communities (patches 8 and 9).
>>
>> v3: Rebase to the current net-next, add the comment only changing
>>     patch 1 and reshuffle some of the patches as requested by Joe.
>>
> 
> All patches looks good to me.
> 
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Series applied.
