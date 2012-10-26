From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Fri, 26 Oct 2012 08:19:15 +0530
Message-ID: <CADAe=+L2hXpYwH-XyNS2HyHQrMQRCmV_v-bs0Qp+sR-mVkzV4A@mail.gmail.com>
References: <CADAe=+KJ2QuL7ZdrfDWQe8R1vF_r_bu3QBS-5kwZBgQ21QTMtg@mail.gmail.com>
 <CAD6jFUTL9-Uyf-0YPwB7Fd5V71NvJh4ameZMF2GCQjDXh_DVzw@mail.gmail.com>
 <CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com> <CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:38016 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab2JZCtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 22:49:45 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so2230425obb.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 19:49:45 -0700 (PDT)
In-Reply-To: <CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> If the driver uses NAPI [1] / the chip supports that, then not. You
> can observe the hardware / software interrupts via ifpps or watching
> procfs or some other tools, or simply look at the driver
> implementation.
>
> [1] http://www.linuxfoundation.org/collaborate/workgroups/networking/napi

But does NAPI comes into picture in case of transmission of packets ?
I read it comes into picture
only in the case of reception of packets.

Regards,
Ajith
