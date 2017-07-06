From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Subject: Re: MPLS Pseudowire (RFC3985) linux kernel support and development
Date: Thu, 06 Jul 2017 16:54:37 +0300
Message-ID: <3114751499349277@web20g.yandex.ru>
References: <1739851499332436@web8m.yandex.ru> <6b8ca117-ae0f-3cb9-0377-5ccb623155d5@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Lamparter <equinox@diac24.net>,
        Amine Kherbouche <amine.kherbouche@6wind.com>
To: Vincent JARDIN <vincent.jardin@6wind.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward5p.cmail.yandex.net ([77.88.31.20]:46663 "EHLO
        forward5p.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751861AbdGFOCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 10:02:15 -0400
In-Reply-To: <6b8ca117-ae0f-3cb9-0377-5ccb623155d5@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I understand it, the patch will be available in the linux kernel or as a separate application based on tap?

06.07.2017, 16:21, "Vincent JARDIN" <vincent.jardin@6wind.com>:
> Le 06/07/2017 à 11:13, Алексей Болдырев a écrit :
>>  Is there any plan for developing mpls pseudowire dliver for linux. And also, is it possible to write a driver for MPLS pseudowire on the basis of tun / tap?
>
> We are working on a RFC patch that should be available soon.
> They'll be tested with FRR.
>
> best regards,
