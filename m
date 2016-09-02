From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next v21 1/4] openvswitch: 802.1ad uapi changes.
Date: Fri, 2 Sep 2016 14:41:48 -0700
Message-ID: <CAOrHB_AkEDzG1JOgWUU-Be1gokSdRDjKvxST6V4PCRrYPLTBzw@mail.gmail.com>
References: <1472762727-25844-1-git-send-email-e@erig.me> <1472762727-25844-2-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Thomas F Herbert <thomasfherbert@gmail.com>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:53319 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbcIBVly (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 17:41:54 -0400
Received: from mfilter32-d.gandi.net (mfilter32-d.gandi.net [217.70.178.163])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 3382441C074
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 23:41:51 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter32-d.gandi.net (mfilter32-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id VLnKlo1FId31 for <netdev@vger.kernel.org>;
        Fri,  2 Sep 2016 23:41:49 +0200 (CEST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id C096741C08F
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 23:41:49 +0200 (CEST)
Received: by mail-it0-f53.google.com with SMTP id e124so61038715ith.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 14:41:49 -0700 (PDT)
In-Reply-To: <1472762727-25844-2-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 1:45 PM, Eric Garver <e@erig.me> wrote:
> From: Thomas F Herbert <thomasfherbert@gmail.com>
>
> openvswitch: Add support for 8021.AD
>
> Change the description of the VLAN tpid field.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
