From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2 net-next 0/9] openvswitch: Conntrack integration improvements.
Date: Wed, 8 Feb 2017 15:54:02 -0800
Message-ID: <CAPWQB7EPBG35ZTQs_2tomTdvhdsuhneJpABPLZMA-N6Ysuw09A@mail.gmail.com>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56008 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbdBHXy1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 18:54:27 -0500
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 87B1C1720B1
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:54:25 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Y1z30zzgPrM7 for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 00:54:24 +0100 (CET)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 1DFD917209F
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:54:23 +0100 (CET)
Received: by mail-qk0-f172.google.com with SMTP id 11so140436577qkl.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:54:23 -0800 (PST)
In-Reply-To: <1486582330-31152-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
> This series improves the conntrack integration code in the openvswitch
> module by fixing bugs (patches 1, 4, and 6), clarifying code (patches
> 2, 3, and 5), improving performance (patch 9), and adding new features
> enabling better translation from firewall admission policy to network
> configuration requested by user communities (patches 7 and 8).

Looks like this needs another rebase.

For the patches I haven't specifically commented on (1,2,4,9), they
looked fine to me:

Acked-by: Joe Stringer <joe@ovn.org>

I presume that Pravin will also want to take a look.
