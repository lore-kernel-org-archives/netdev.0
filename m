From: Vincent JARDIN <vincent.jardin@6wind.com>
Subject: Re: MPLS Pseudowire (RFC3985) linux kernel support and development
Date: Thu, 6 Jul 2017 15:21:43 +0200
Message-ID: <6b8ca117-ae0f-3cb9-0377-5ccb623155d5@6wind.com>
References: <1739851499332436@web8m.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Lamparter <equinox@diac24.net>,
        Amine Kherbouche <amine.kherbouche@6wind.com>
To: =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:36704 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752753AbdGFNVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 09:21:46 -0400
Received: by mail-wr0-f174.google.com with SMTP id c11so2762859wrc.3
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 06:21:46 -0700 (PDT)
In-Reply-To: <1739851499332436@web8m.yandex.ru>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/07/2017 à 11:13, Алексей Болдырев a écrit :
> Is there any plan for developing mpls pseudowire dliver for linux. And also, is it possible to write a driver for MPLS pseudowire on the basis of tun / tap?
> 

We are working on a RFC patch that should be available soon.
They'll be tested with FRR.

best regards,
