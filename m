From: Steve Glendinning <steve@shawell.net>
Subject: Re: smsc75xx maintainer?
Date: Fri, 17 Aug 2012 09:05:03 +0100
Message-ID: <CAKh2mn76cAUL0Do40FcV_BAXU89YaMixAPYmNxe1KL-f-aByUQ@mail.gmail.com>
References: <CANEJEGuh++1-7HajcK65a=NPyKY_5JWkjGQFOKddv4JrVn0gFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54700 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030759Ab2HQIFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 04:05:03 -0400
Received: by obbuo13 with SMTP id uo13so4938121obb.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 01:05:03 -0700 (PDT)
In-Reply-To: <CANEJEGuh++1-7HajcK65a=NPyKY_5JWkjGQFOKddv4JrVn0gFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

On 15 August 2012 22:48, Grant Grundler <grundler@google.com> wrote:
>
> scripts/get_maintainer.pl can't identify an owner for
> drivers/net/usb/smsc75xx.c (USB GigE dongle).

Thanks for spotting this, I've submitted a patch to add the missing
entry to MAINTAINERS

> Anyone (at SMSC?) interested in fixing suspend/resume for smsc75xx driver?
>
> I don't have time to chase this but it would be nice if this part
> worked. Only suspend/resume appears broken.
>
> Some details in http://crosbug.com/31871.

I'll look into it, thanks.

--
Steve Glendinning
