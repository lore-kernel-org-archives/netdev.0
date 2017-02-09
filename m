From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 00/10] openvswitch: Conntrack integration improvements.
Date: Thu, 9 Feb 2017 08:44:55 -0800
Message-ID: <CAOrHB_CiVOAQzBpFccZrnuS2Aa2YpdjnGeoivahy+MCdjuw1cQ@mail.gmail.com>
References: <1486603837-7202-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:53675 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbdBIQpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:45:00 -0500
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 93E5DFB8CB
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 17:44:57 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id BAgqCqVdWiZv for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 17:44:56 +0100 (CET)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 5223CFB8E5
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 17:44:56 +0100 (CET)
Received: by mail-wm0-f54.google.com with SMTP id r141so25232563wmg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 08:44:56 -0800 (PST)
In-Reply-To: <1486603837-7202-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 5:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> This series improves the conntrack integration code in the openvswitch
> module by fixing outdated comments (patch 1), bugs (patches 2, 3, and
> 7), clarifying code (patches 4, 5, and 6), improving performance
> (patch 10), and adding new features enabling better translation from
> firewall admission policy to network configuration requested by user
> communities (patches 8 and 9).
>
> v3: Rebase to the current net-next, add the comment only changing
>     patch 1 and reshuffle some of the patches as requested by Joe.
>

All patches looks good to me.

Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks.
