From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 0/4] geneve: Use LWT more effectively.
Date: Mon, 21 Nov 2016 11:03:48 -0800
Message-ID: <CAOrHB_AL7V3NgqndLkho_YuNOoaawA252HjWzN4tMify+q9SVw@mail.gmail.com>
References: <1479521411-53012-1-git-send-email-pshelar@ovn.org> <20161121.112853.596026767987561055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:55443 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754028AbcKUTDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 14:03:54 -0500
Received: from mfilter26-d.gandi.net (mfilter26-d.gandi.net [217.70.178.154])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id ECE6BFB87E
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 20:03:51 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter26-d.gandi.net (mfilter26-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id QyV0by6oMJBE for <netdev@vger.kernel.org>;
        Mon, 21 Nov 2016 20:03:50 +0100 (CET)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 2A454FB8A4
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 20:03:50 +0100 (CET)
Received: by mail-it0-f46.google.com with SMTP id j191so111840556ita.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 11:03:50 -0800 (PST)
In-Reply-To: <20161121.112853.596026767987561055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 8:28 AM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@ovn.org>
> Date: Fri, 18 Nov 2016 18:10:07 -0800
>
>> Following patch series make use of geneve LWT code path for
>> geneve netdev type of device.
>> This allows us to simplify geneve module.
>>
>> v1-v2:
>> Fix warning reported by kbuild test robot.
>
> This doesn't apply cleanly to net-next, please respin.
>

Sure. I have posted updated series.

Thanks.
