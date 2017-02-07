From: David Miller <davem@davemloft.net>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 1/2] flow dissector: ND
 support
Date: Tue, 07 Feb 2017 12:38:31 -0500 (EST)
Message-ID: <20170207.123831.1038511845714033360.davem@davemloft.net>
References: <CALx6S37QtKgc14DFway-Ajme7JhbAN71M+83w28+4FELdv7Xew@mail.gmail.com>
        <20170206091253.GB20384@penelope.horms.nl>
        <CALx6S351OxEtGhjBdGVGUF7JcBRjpY3hwft-hXjxix7EVAfhQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, jiri@resnulli.us,
        eric.dumazet@gmail.com, dinan.gunawardena@netronome.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753433AbdBGRie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:38:34 -0500
In-Reply-To: <CALx6S351OxEtGhjBdGVGUF7JcBRjpY3hwft-hXjxix7EVAfhQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 7 Feb 2017 09:36:20 -0800

> Okay, but can you give us an idea of how many more of these protocols
> are going to be added to flow_dissector. TBH I'm not very enthused
> about making more flow_dissector more complex for the benefit of OVS.

Especially since the kernel datapath of OVS has been marked
experimental.
