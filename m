From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: does the broadcom bnx2x support RSS/multi queue
Date: Wed, 12 May 2010 11:59:54 +0200
Message-ID: <1273658394.2621.26.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
	 <1273650119.2621.5.camel@edumazet-laptop>
	 <1273655947.4491.5.camel@lb-tlvb-eilong.il.broadcom.com>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85DCD@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "eilong@broadcom.com" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58441 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265Ab0ELJ76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 05:59:58 -0400
Received: by fxm15 with SMTP id 15so131610fxm.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 02:59:57 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85DCD@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 mai 2010 =C3=A0 02:34 -0700, Jon Zhou a =C3=A9crit :
> hi eilon:
>=20
> do you think I need to update the kernel also?
>=20
> thanks!
> jon

I believe both of us (Eilong and me) stated your kernel version was too
old.

In order to play with multiqueue, you should use a very recent kernel,
or hit various bottlenecks and bugs.



