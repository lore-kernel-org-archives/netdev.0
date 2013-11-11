From: Veaceslav Falico <veaceslav@falico.eu>
Subject: Re: bridge not getting ip since 3.11.5 and 3.4.66
Date: Mon, 11 Nov 2013 12:07:30 +0100
Message-ID: <CAE3RKNng9A6Bp7wa4+6iCprwEQpzGueagLc8iob+aFabJW4nnw@mail.gmail.com>
References: <CAEPa5ym2Xz3F19fJJqNawkRLOKk6Ao6oXrzSrHU051V7p=9otA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mark Trompell <mark@foresightlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57558 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab3KKLHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 06:07:51 -0500
Received: by mail-pd0-f169.google.com with SMTP id y13so2218371pdi.14
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 03:07:50 -0800 (PST)
In-Reply-To: <CAEPa5ym2Xz3F19fJJqNawkRLOKk6Ao6oXrzSrHU051V7p=9otA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 11:29 AM, Mark Trompell <mark@foresightlinux.org> wrote:
> my bridge br0 doesn't get an ip from dhcp anymore after 3.11.5 and 3.4.66,
> What information would be helpful and required to find out what's going wrong.

CC netdev

First thing would be to provide the network scheme. Do you use vlans?
Which network
cards/drivers are you using? Do you use some kind of virtualization?
Is bonding involved?

>
> Greetings
> Mark
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Best regards,
Veaceslav Falico
