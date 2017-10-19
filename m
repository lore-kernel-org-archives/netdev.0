From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] wanxl: use m68k-linux-gnu-as if available
Date: Thu, 19 Oct 2017 19:25:17 +0200
Message-ID: <m3y3o7nj7m.fsf@pm.waw.pl>
References: <20171012232434.15890-1-kilobyte@angband.pl>
        <20171018.120812.879877583327430024.davem@davemloft.net>
        <20171018113326.2rkpe7wrlzihwdyb@angband.pl>
        <20171018.130721.1208428223967129203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kilobyte@angband.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([91.202.125.194]:33449 "EHLO inx.pm.waw.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751974AbdJSRep (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 13:34:45 -0400
In-Reply-To: <20171018.130721.1208428223967129203.davem@davemloft.net> (David
        Miller's message of "Wed, 18 Oct 2017 13:07:21 +0100 (WEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> We don't even know if whatever "as68k" is would be the same thing
> as GNU as and generate the same binaries.

It's GNU as, likewise ld68k, though I have no idea if recent versions
would compile/link the firmware (correctly). This is 15+ years old.

I don't have opinion on the patch.
-- 
Krzysztof Halasa
