From: Dustin Schumm <shodid@gmail.com>
Subject: Re: Reoccuring kern.log events after running xl2tp with ethernet
 adapter Realtek 8111E
Date: Tue, 5 Jun 2012 11:59:47 -0400
Message-ID: <CANcVnzj-DUD8x9jcj3awyWkZjH9x5PMf3fAFtR_osPNAU9adgA@mail.gmail.com>
References: <CANcVnzi2mXKXZLcaAt9rJ9OOdK_2=V8JV9uebVeBcsDu6j+DhQ@mail.gmail.com>
	<CANcVnzivnQrhSderZ+b5yoy+F1OiO7Ajv7WeijqzQKyAkYRqug@mail.gmail.com>
	<20120605153753.GA12514@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:54037 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab2FEP7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 11:59:49 -0400
Received: by wgbdr13 with SMTP id dr13so5283288wgb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 08:59:48 -0700 (PDT)
In-Reply-To: <20120605153753.GA12514@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 5, 2012 at 11:37 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>
> This is with an usual 1500 bytes MTU and without TSO (see 'ethtool -k ethX'),
> right ?
>
> --
> Ueimor

Yes,

MTU:1500
tcp-segmentation-offload: off
