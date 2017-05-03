From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Subject: Re: Maximum MPLS labels on Linux network stack
Date: Thu, 04 May 2017 00:29:05 +0300
Message-ID: <454271493846945@web51g.yandex.ru>
References: <149211493832787@web33j.yandex.ru> <5a408c23-d3e2-aa3e-4574-82521b2255b0@gmail.com>
         <CAPWQB7FFwBFL9h7JoJMF4FuK7JXLrHfo5yg4aHJ4iczSdNU_bg@mail.gmail.com> <443301493846392@web51g.yandex.ru> <CAPWQB7HrbCVLEjaR0hObPTxrDg8qyfZo-3iYLe=NVzuPTOLxCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Ahern <dsahern@gmail.com>, netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1p.cmail.yandex.net ([77.88.31.16]:53070 "EHLO
        forward1p.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751621AbdECVgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 17:36:49 -0400
In-Reply-To: <CAPWQB7HrbCVLEjaR0hObPTxrDg8qyfZo-3iYLe=NVzuPTOLxCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I understand it, it's enough to just set the variable in the source
#define FLOW_MAX_MPLS_LABELS 3
on
#define FLOW_MAX_MPLS_LABELS 7
Or is there somehow still pitfalls?

04.05.2017, 00:22, "Joe Stringer" <joe@ovn.org>:
> On 3 May 2017 at 14:19, Алексей Болдырев
> <devel-net-ne-vlezay80@yandex.ru> wrote:
>>  Is it possible to increase this limit in OpenVswitch?
>
> Yes.
