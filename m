From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: does the broadcom bnx2x support RSS/multi queue
Date: Mon, 17 May 2010 10:12:59 +0200
Message-ID: <1274083979.2293.2.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85D43@MILEXCH2.ds.jdsu.net>
	 <1273650119.2621.5.camel@edumazet-laptop>
	 <1273655947.4491.5.camel@lb-tlvb-eilong.il.broadcom.com>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85DCD@MILEXCH2.ds.jdsu.net>
	 <1273658394.2621.26.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497E68B24@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "eilong@broadcom.com" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:1298 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab0EQINF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 04:13:05 -0400
Received: by fg-out-1718.google.com with SMTP id 22so408625fge.1
        for <netdev@vger.kernel.org>; Mon, 17 May 2010 01:13:03 -0700 (PDT)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497E68B24@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 mai 2010 =C3=A0 01:05 -0700, Jon Zhou a =C3=A9crit :
> hi eric:
>=20
> "very recent kernel" -- do you you mean "receive packet steering"?
>=20

Not necessarly. RPS is the "poor man solution", when multique NICS are
not available, or a refinement over it on special cases.

I would say 2.6.33.4 or 2.6.34 would be ok.



