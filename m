From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Porting ethernet over spi driver
Date: Mon, 21 Apr 2014 23:32:56 -0300
Message-ID: <CAOMZO5B-=6rqRgTVS+O+dDWq0SDE9_ytKdW38gN=gzzy-xwEtw@mail.gmail.com>
References: <5350ED9E.6080103@lategoodbye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Wahren <info@lategoodbye.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:44071 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaDVCc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 22:32:58 -0400
Received: by mail-we0-f175.google.com with SMTP id q58so4403945wes.34
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 19:32:56 -0700 (PDT)
In-Reply-To: <5350ED9E.6080103@lategoodbye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2014 at 6:17 AM, Stefan Wahren <info@lategoodbye.de> wrote:
> Hi,
>
> i'm trying to port a ethernet over spi driver to current mainline, which
> originally based on kernel 2.6.
>
> Now i'm searching for some guidelines, checklists, common pitfalls or just
> hints about that.
>
> Is there something about that, which is up to date?
>
> Is there a list or something of legacy function, which shouldn't be used
> anymore?
>
> Are there any new must have features?
>
> Is there a good reference implementation for ethernet over spi?

Not sure if it is a good reference, but the only one I am aware of is this one:
drivers/net/ethernet/microchip/enc28j60.c

Regards,

Fabio Estevam
