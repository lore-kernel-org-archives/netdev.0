From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: NAT question
Date: Wed, 25 Jan 2012 17:47:18 +0100
Message-ID: <CAFLxGvyLnWO4ju42FcU-oW188i9GtgkuktVMiLww5kFHbhBOYw@mail.gmail.com>
References: <4F2025BD.20903@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:49630 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756008Ab2AYQrT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 11:47:19 -0500
Received: by obcva7 with SMTP id va7so5702300obc.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 08:47:18 -0800 (PST)
In-Reply-To: <4F2025BD.20903@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2012 at 4:54 PM, Stephen Clark <sclark46@earthlink.net>=
 wrote:
> Can iptables do a network to network nat without having to write out =
a bunch
> of nat rules.
> In other words translate =A0192.168.198.0/24 to 172.16.10.0/24 withou=
t having
> to write out
> 256 rules.
>

Maybe the NETMAP target is the right thing for you.

--=20
Thanks,
//richard
