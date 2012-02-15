From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: About bnx2-mips-09-6.2.1b.fw (Broadcom ethernet) firmware
Date: Tue, 14 Feb 2012 21:50:00 -0800
Message-ID: <CAHLZz11wU4sKtq6wD_ZFaOH+6QU-JTYgXFV6Vs1qucMa26a0fw@mail.gmail.com>
References: <CAP+Vy9cSK7kWbfYGT566BshozaQ-NqH0UpeuXEErLRLMP9Tt0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Dongsoo Nathaniel Kim <dongsoo.kim@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38255 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab2BOFuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 00:50:01 -0500
Received: by vbjk17 with SMTP id k17so519797vbj.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 21:50:00 -0800 (PST)
In-Reply-To: <CAP+Vy9cSK7kWbfYGT566BshozaQ-NqH0UpeuXEErLRLMP9Tt0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 9:26 PM, Dongsoo Nathaniel Kim
<dongsoo.kim@gmail.com> wrote:
> Hello folks,
>
> I'm wondering if it is ok to send a patch which includes
> bnx2-mips-09-6.2.1b.fw.ihex.
>

firmware is no longer distributed with kernel source, there is a
separate firmware repo:

git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git

Where you'll find the above file is already incuded in the bnx2/ folder

Cheers,

Harvey
