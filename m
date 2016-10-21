From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 8/9] openvswitch: allow L3 netdev ports
Date: Thu, 20 Oct 2016 21:22:31 -0700
Message-ID: <CAOrHB_CdK4FjTWm=vvemUgU8BYiYZc++_6Hguq5aE0gofxD8Hw@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <4ed33e7c676bdd876a2cc4b5bcbf92851a5727f7.1476708213.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:36093 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753229AbcJUEWf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 00:22:35 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 86B57172094
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:22:34 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id KFPlVl2Djd_c for <netdev@vger.kernel.org>;
        Fri, 21 Oct 2016 06:22:33 +0200 (CEST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id F2DD1172097
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:22:32 +0200 (CEST)
Received: by mail-it0-f41.google.com with SMTP id m138so139618350itm.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 21:22:32 -0700 (PDT)
In-Reply-To: <4ed33e7c676bdd876a2cc4b5bcbf92851a5727f7.1476708213.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Allow ARPHRD_NONE interfaces to be added to ovs bridge.
>
> Based on previous versions by Lorand Jakab and Simon Horman.
>
> Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
