From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Enable tx timestamping on loopback and dummy
Date: Sun, 12 Mar 2017 17:30:00 +0100
Message-ID: <20170312163000.GA1649@localhost.localdomain>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
 <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ezequiel Lara Gomez <ezegomez@amazon.com>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36604 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755675AbdCLQaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 12:30:06 -0400
Received: by mail-wr0-f194.google.com with SMTP id l37so17267077wrc.3
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 09:30:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 12:17:30AM +0100, Oliver Hartkopp wrote:
> in fact you're doing three different things here:
> 
> 1. introduce tx timestamping
> 2. silently change an include: <asm/io.h> -> <linux/io.h>
> 3. fix some whitespace and empty line issues
> 
> You'd better provide one patch for 1 & 2 and explain why 2 is needed.

And while you are at it, explain why #1 is needed.

Thanks,
Richard
