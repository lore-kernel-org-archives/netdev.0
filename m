From: emin ak <eminak71@gmail.com>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path (Was Re: [Bugme-new] [Bug
 19692] New: linux-2.6.36-rc5 crash with gianfar ethernet at full line rate traffic)
Date: Fri, 22 Oct 2010 08:42:10 +0300
Message-ID: <AANLkTimakJjwL9v2Ztpce3Xnjb_r5XB=rGoJc9pZKE12@mail.gmail.com>
References: <20101010103236.GA1919@del.dom.local>
	<20101015085853.GA8091@ff.dom.local>
	<AANLkTinAj=9-RqNA6xKc_5ONz2hPMRGM8uJ2Xy7XJVdr@mail.gmail.com>
	<20101016194815.GA1894@del.dom.local>
	<AANLkTi=08Myz1=XOHkGJWTdyC8vK+y+zf0UQhjxUi=qC@mail.gmail.com>
	<20101019100636.GA9246@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Anton Vorontsov <avorontsov@mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51135 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab0JVFmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 01:42:11 -0400
Received: by iwn34 with SMTP id 34so472120iwn.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 22:42:11 -0700 (PDT)
In-Reply-To: <20101019100636.GA9246@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek;

> Maybe for now let's try to get and see this type 1 again? Since the
> recycle path is suspicious a bit to me, probably limiting memory or
> slowing tx (maybe different mtus on eth0 and 1) under heavy multi cpu
> load might help.
>

I'll do my best with your recommended test conditions. I have reserved
a machine and two ports of  hw packet generator, now we'll see if this
error will occur again or not. (But I'am not sure if I want to see it
again:)
Thanks
Emin
