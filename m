From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Sun, 22 Jul 2012 20:32:26 -0400
Message-ID: <CABF+-6XVWpaw6zQe2XNaz4y3oj-KdDm63vbut5jAxs3RWRC6LQ@mail.gmail.com>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	<20120722.145454.943592825984584407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:33921 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab2GWAc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 20:32:27 -0400
Received: by vbbff1 with SMTP id ff1so4220502vbb.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 17:32:26 -0700 (PDT)
In-Reply-To: <20120722.145454.943592825984584407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 22, 2012 at 5:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Kevin Groeneveld <kgroeneveld@gmail.com>
> Date: Sun, 22 Jul 2012 16:19:56 -0400
>
>> Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
>
> I don't see this as being very practical nor justified.

It is obviously not up to me to decide what is practical or justified
in this case.  I am just always annoyed when I log into my Linksys
router and check the network stats for my PPP interface and have no
idea how many times the transfer stats have rolled over at 4GB.


Kevin
