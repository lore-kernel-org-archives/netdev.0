From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] iproute2: build nsid-name cache only for commands that
 need it
Date: Fri, 16 Sep 2016 11:44:22 +0200
Message-ID: <905de9c1-1322-5468-5770-58f788cb972c@6wind.com>
References: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal>
 <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
 <CAMw6YJJuoA+Z_DQx8iSEkrurB4ZZN9MePtHEeW=q7t5aDvmSAA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Anton Aksola <aakso@iki.fi>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37357 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754906AbcIPJo0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:44:26 -0400
Received: by mail-wm0-f44.google.com with SMTP id k186so30875925wmd.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 02:44:26 -0700 (PDT)
In-Reply-To: <CAMw6YJJuoA+Z_DQx8iSEkrurB4ZZN9MePtHEeW=q7t5aDvmSAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/09/2016 à 11:23, Vadim Kochan a écrit :
[snip]
> Would it be useful to add test for this case into testsuite/ ?
Yes, it's a good idea.

Regards,
Nicolas
