From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 3/3] openvswitch: use mpls_hdr
Date: Fri, 30 Sep 2016 11:20:47 -0700
Message-ID: <CAOrHB_BmHthNodFm4PGEQ2STrmxYU=dBk2ouR2nDi6EHB3BKSw@mail.gmail.com>
References: <cover.1475255100.git.jbenc@redhat.com> <672d97cf2e761276a9390b72265606bb5cbb6bb6.1475255100.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:43839 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932972AbcI3SUv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 14:20:51 -0400
Received: from mfilter43-d.gandi.net (mfilter43-d.gandi.net [217.70.178.174])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 2F1D941C088
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 20:20:50 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter43-d.gandi.net (mfilter43-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id MmMUn-9_3Q0I for <netdev@vger.kernel.org>;
        Fri, 30 Sep 2016 20:20:48 +0200 (CEST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id AD14841C08D
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 20:20:48 +0200 (CEST)
Received: by mail-it0-f41.google.com with SMTP id r192so59000562ita.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 11:20:48 -0700 (PDT)
In-Reply-To: <672d97cf2e761276a9390b72265606bb5cbb6bb6.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 10:08 AM, Jiri Benc <jbenc@redhat.com> wrote:
> skb_mpls_header is equivalent to mpls_hdr now. Use the existing helper
> instead.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
