From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 12:21:28 -0700
Message-ID: <4735D473-34CB-4530-8FA5-D105151E02D8@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost> <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
 <20170327142925.GA13305@localhost.localdomain>
 <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com> <20170327182828.GA2254@netboy>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:39177 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdC0TVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 15:21:32 -0400
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0ONH00800N2RX300@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Mon, 27 Mar 2017 19:21:30 +0000 (GMT)
In-reply-to: <20170327182828.GA2254@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resend in plain text for vger]

> On Mar 27, 2017, at 11:28, Richard Cochran <richardcochran@gmail.com> =
wrote:
>=20
> I didn't do anything super methodical, and I didn't keep notes, but I
> had a phyter (whose delays were published by TI and independently
> confirmed in a ISPCS paper by Christian Riesch) and an i210 with a 100
> MBit link and with a PPS between them.  The phyter's numbers are
> correct to within a nanosecond, and I saw that the i210 was repeatedly
> landing at the published extreme of the range.  I don't remember which
> extreme, and I didn't repeat more than a few times, however.

Do you still have the resulting correction values from this?

Thanks,
Denny
