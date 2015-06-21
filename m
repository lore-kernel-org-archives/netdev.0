From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/3 v5] changes to make ipv4 routing table aware
 of next-hop link status
Date: Sat, 20 Jun 2015 22:36:44 -0700
Message-ID: <CAE4R7bBpqxU=hEwgh=oX6ugu1vF-y+Lh5BqSizg3EUB5ZireEg@mail.gmail.com>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36164 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbbFUFhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 01:37:04 -0400
Received: by oigb199 with SMTP id b199so61984417oig.3
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 22:37:03 -0700 (PDT)
In-Reply-To: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 8:22 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> This series adds the ability to have the Linux kernel track whether or
> not a particular route should be used based on the link-status of the
> interface associated with the next-hop.

[cut]

> Andy Gospodarek (3):
>   net: track link-status of ipv4 nexthops
>   net: ipv4 sysctl option to ignore routes when nexthop link is down
>   iproute2: add support to print 'linkdown' nexthop flag

On the series:

Acked-by: Scott Feldman <sfeldma@gmail.com>
