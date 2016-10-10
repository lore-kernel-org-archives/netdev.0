From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 3/3] openvswitch: add NETIF_F_HW_VLAN_STAG_TX to
 internal dev
Date: Mon, 10 Oct 2016 13:05:46 -0700
Message-ID: <CAOrHB_B==c5LS1affOULViOov7guvvx2M1eSvnKHftS4S+Fsog@mail.gmail.com>
References: <cover.1476111550.git.jbenc@redhat.com> <688ddda46c331c1b85450d6f28b1441af6cee1de.1476111550.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:60489 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbcJJUFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 16:05:51 -0400
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 68847A80C4
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 22:05:49 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 2wQ-OkdTHlmE for <netdev@vger.kernel.org>;
        Mon, 10 Oct 2016 22:05:48 +0200 (CEST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id DEF5FA80CE
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 22:05:47 +0200 (CEST)
Received: by mail-it0-f49.google.com with SMTP id o19so3437462ito.1
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 13:05:47 -0700 (PDT)
In-Reply-To: <688ddda46c331c1b85450d6f28b1441af6cee1de.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 8:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> The internal device does support 802.1AD offloading since 018c1dda5ff1
> ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink
> attributes").
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
