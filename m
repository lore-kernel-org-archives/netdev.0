From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 doesn't report link state correctly.
Date: Wed, 20 Apr 2011 21:14:03 +0200
Message-ID: <20110420191403.GC18805@electric-eye.fr.zoreil.com>
References: <4DA35FEF.1030009@candelatech.com> <20110413174815.GB17579@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52425 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab1DTTWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:22:10 -0400
Content-Disposition: inline
In-Reply-To: <20110413174815.GB17579@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ran=C3=A7ois Romieu <romieu@fr.zoreil.com> :
> On Mon, Apr 11, 2011 at 01:09:19PM -0700, Ben Greear wrote:
> > I notice that in kernel 2.6.38-wl, the realtek 8169 NIC doesn't
> > report link down when in fact there is no cable connected.  Instead=
,
[...]
> Thanks for the report. I'll try it tomorrow or friday.

I have not been able to notice it with a current kernel.

I'd welcome the XID of the 8169 NIC (see dmesg) and a short explanation
(no cable from boot ? cable removed after ifconfig up ? brand / ability
of the switch / hub ?).

Thanks.

--=20
Ueimor
