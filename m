From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: Testing server performance
Date: Mon, 12 Dec 2011 10:24:15 +0100
Message-ID: <CAFdo_mU-CHP0tyScF_ZmZJHeSuC6MEgASTZ+h2JWyumTn=sqqw@mail.gmail.com>
References: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
	<4EE242DF.2000609@candelatech.com>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:40627 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386Ab1LLJY1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 04:24:27 -0500
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id F2A771200FA
	for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 10:24:25 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id mugAREgGiwnt for <netdev@vger.kernel.org>;
	Mon, 12 Dec 2011 10:24:17 +0100 (CET)
Received: from mail-gx0-f174.google.com (mail-gx0-f174.google.com [209.85.161.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id E303A60138
	for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 10:24:16 +0100 (CET)
Received: by ggdk6 with SMTP id k6so827811ggd.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 01:24:15 -0800 (PST)
In-Reply-To: <4EE242DF.2000609@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Check the bus speed and width on your NICs. =A0dmesg usually shows th=
is
> info when the interfaces are first detected.
>
> If you can, try some Intel NICs..they will usually run wire speed
> if the motherboard is reasonably fast.
>
> Thanks,
> Ben

Thanks for the advice.
I' ll see if I can find some Intel NICs.

NIC's specs says that they support 32-bit 33/66MHz clock speed PCI Bus
Master operation.
Should that be enough?

I'll see what dmesg showed tomorow, because I'm not at my computer curr=
ently.
BR
Igor
