From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v4 4/4] Openvswitch:
 Refactor sample and recirc actions implementation
Date: Tue, 21 Mar 2017 22:59:57 -0700
Message-ID: <CAOrHB_C8BiTqgwAKMBUKSv4FXVVmk5m6ty+qRroJ7ofjCB-6wQ@mail.gmail.com>
References: <1490052750-60187-1-git-send-email-azhou@ovn.org> <1490052750-60187-5-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:44295 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758514AbdCVGAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 02:00:48 -0400
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 9C0DFC5A61
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:59:59 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id xMkHPTn6538w for <netdev@vger.kernel.org>;
        Wed, 22 Mar 2017 06:59:58 +0100 (CET)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 326FFC5A43
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:59:58 +0100 (CET)
Received: by mail-wm0-f50.google.com with SMTP id n11so27436683wma.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 22:59:58 -0700 (PDT)
In-Reply-To: <1490052750-60187-5-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 4:32 PM, Andy Zhou <azhou@ovn.org> wrote:
> Added clone_execute() that both the sample and the recirc
> action implementation can use.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>

Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks for working on this.
