From: Francisco Castello <franciscocastello@gmail.com>
Subject: Re: About filtering IPv6
Date: Tue, 27 May 2014 17:25:25 -0300
Message-ID: <CAOMv-nPdTqX8V+CuV0UThpn48_X8E9+j72NG+pbvjJ50mA2vMg@mail.gmail.com>
References: <CAOMv-nPU+HxPvzrHSzcrvJdP4MpNvN69X1NDaESjaDNK_MwSUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:54366 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaE0UZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 16:25:46 -0400
Received: by mail-ig0-f176.google.com with SMTP id hl10so1578244igb.9
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 13:25:46 -0700 (PDT)
In-Reply-To: <CAOMv-nPU+HxPvzrHSzcrvJdP4MpNvN69X1NDaESjaDNK_MwSUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I know I can make trafic shaping if ipv6 with tc filter. But what I
want to know if there is already support for shaping IPv6 Packets
marked with ip6tables.
I know there is an issue of IPv6 not being implemented in the Routing
Policy Database (RPDB) so packets marked with ip6tables are ignored in
shaping queues.. I want to know if this is fixed or you are planning
on fixing it or if there is a workaround for this issue.
If there is none I could get involved on fixing it but I don't know
where to start digging.
Sorry for my question but there is very little documentation about
ipv6 in linux routing.

Thanks in advance

Francisco Castello
