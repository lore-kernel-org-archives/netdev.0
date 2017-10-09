From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCHv2 net-next] openvswitch: Add erspan tunnel support.
Date: Sun, 8 Oct 2017 21:45:06 -0700
Message-ID: <CAOrHB_Cq=OptnWy3GMgO-HZmtELYKeDhv8+MG0Qqm-jAsed89Q@mail.gmail.com>
References: <1507161792-18340-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:38201 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbdJIEpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:45:09 -0400
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id D0D8341C080
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 06:45:07 +0200 (CEST)
Received: by mail-wm0-f50.google.com with SMTP id t69so19015054wmt.2
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:45:07 -0700 (PDT)
In-Reply-To: <1507161792-18340-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 4, 2017 at 5:03 PM, William Tu <u9012063@gmail.com> wrote:
> Add erspan netlink interface for OVS.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Pravin B Shelar <pshelar@ovn.org>
> ---
> v1->v2: remove unnecessary compat code.

Looks good to me.
