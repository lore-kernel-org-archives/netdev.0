From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Thu, 02 Feb 2012 18:48:56 +0100
Message-ID: <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50218 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823Ab2BBRtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 12:49:01 -0500
Received: by wgbdt10 with SMTP id dt10so2879759wgb.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 09:49:00 -0800 (PST)
In-Reply-To: <1328203710.5553.94.camel@leeds.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 17:28 +0000, Wei Liu a =C3=A9crit =
:

> You're right about this.
>=20
> But this part is destined to get wiped out (in the very near future?)=
 --
> see following patches. So I don't think it is worthy to fix this.
>=20

Before adding new bugs, you must fix previous ones.

Do you think stable teams will do the backport of all your upcoming
patches ?
