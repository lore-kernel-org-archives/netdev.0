From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: caif BUG() with network namespaces
Date: Fri, 21 Oct 2011 23:55:23 +0200
Message-ID: <CAJK669a0cX73J0pEr3EtCkbxsaHRfxnS-56Q3Q5ANdKd47mnrg@mail.gmail.com>
References: <1319230309.19448.10.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Woodhouse, David" <david.woodhouse@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50661 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab1JUVzY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 17:55:24 -0400
Received: by qabj40 with SMTP id j40so3256548qab.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 14:55:24 -0700 (PDT)
In-Reply-To: <1319230309.19448.10.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> When Chrome initialises its sandbox, we get a BUG:
>
> [ =C2=A0 63.674528] ------------[ cut here ]------------
> [ =C2=A0 63.674540] kernel BUG at net/caif/caif_dev.c:66!
=2E..
> Is this already known/fixed?
>
> https://bugs.meego.com/show_bug.cgi?id=3D23540

No, I'm afraid I haven't seen this one before. But I'm afraid we
haven't tested much with net-namespaces enabled either.

Regards,
Sjur
