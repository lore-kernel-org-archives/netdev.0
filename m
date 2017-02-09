From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v4 net-next 06/10] openvswitch: Refactor labels initialization.
Date: Thu, 9 Feb 2017 13:46:33 -0800
Message-ID: <CAPWQB7F9AQ10HRQkPpyn8TL2bgBtk3OJvtsgOO+BcDASDT4uYA@mail.gmail.com>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org> <1486668121-45709-7-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:41603 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752637AbdBIXxX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 18:53:23 -0500
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 5C79347EAFB
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:48:42 +0100 (CET)
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id EE6D141C074
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:46:56 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 95MkjwOTqViS for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 22:46:55 +0100 (CET)
Received: from mail-qt0-f179.google.com (mail-qt0-f179.google.com [209.85.216.179])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 4BC1541C080
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:46:55 +0100 (CET)
Received: by mail-qt0-f179.google.com with SMTP id w20so17441197qtb.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 13:46:55 -0800 (PST)
In-Reply-To: <1486668121-45709-7-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 February 2017 at 11:21, Jarno Rajahalme <jarno@ovn.org> wrote:
> Refactoring conntrack labels initialization makes changes in later
> patches easier to review.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
