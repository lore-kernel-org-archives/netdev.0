From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Sun, 30 Nov 2014 11:18:06 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411301112330.1477@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com> <54781523.6030600@audiocodes.com>
 <alpine.LNX.2.03.1411280923230.3997@gmail.com> <54783443.50700@audiocodes.com> <alpine.LNX.2.03.1411280944200.4040@gmail.com> <54783A1D.3090607@audiocodes.com> <alpine.LNX.2.03.1411281014450.4101@gmail.com> <54783F84.20105@audiocodes.com>
 <alpine.LNX.2.03.1411300202310.4742@gmail.com> <CAPChA0czA3vxPZdwk-SgO1Wr83zOV1UoWcL4=05qtBktwq5=TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eli Britstein <Eli.Britstein@audiocodes.com>,
	linux-usb@vger.kernel.org, "youtux@gmail.com" <youtux@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: Alex Strizhevsky <alexxst@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37102 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbaK3KRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 05:17:39 -0500
In-Reply-To: <CAPChA0czA3vxPZdwk-SgO1Wr83zOV1UoWcL4=05qtBktwq5=TA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry - by error I did not send the message to all.
Hi everyone, and good Sunday!
The problem is that - between those two firmwares things might change, and so 
we don't know what Windows does when it meets this specific branch /version of 
the firmware.
I am desperately suspecting that we would not get anything hinting a lot even 
looking at the usb capture of this specific firmware, but... in any case it 
might be interesting to have it.
(at+gmr returns the firmware revision)
Is the dongles with 23 firmwares working under Linux?
Or, you might upgrade all dongles firmware until all of then are running the 23 
version and so workaround the problem differently in case.
Bjorn: I noticed that anyway, as Alex suggested, tcpdump can reveal some
traffic: in particular you can see the gateway asking for us ... but no
traffic can flow out, only flow in.
The system can see traffic coming in, not generate it. Any idea or comment
from anyone is welcome.
