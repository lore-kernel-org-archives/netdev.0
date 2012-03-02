From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: Resend: [PATCH] Bluetooth: Fix Endian Bug.
Date: Fri, 2 Mar 2012 14:32:15 +0200
Message-ID: <20120302123210.GA4741@aemeltch-MOBL1>
References: <1330599561-20392-1-git-send-email-santoshprasadnayak@gmail.com>
 <20120301123540.GE25627@aemeltch-MOBL1>
 <CAOD=uF4LSS8nuKMNHGEH2JsVZHU0rntSxZjvNaa4oZrey1macw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh prasad nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOD=uF4LSS8nuKMNHGEH2JsVZHU0rntSxZjvNaa4oZrey1macw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Santosh,

On Thu, Mar 01, 2012 at 07:34:58PM +0530, santosh prasad nayak wrote:
> Andrei,
>=20
> I could not get you.
>=20
> Do you want me to resend the patch with subject,
>   "[PATCH] Bluetooth: Fix network to host endian conversion for L2CAP
> chan id."  ?

No, the main concern was your commit message which is changelog and sho=
uld
come after "---" as it is shown in the example below.

> > On Thu, Mar 01, 2012 at 04:29:21PM +0530, santosh nayak wrote:
> >> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> >>
> >> Fix for endian bug.
> >>
> >> Fix for null dereferenced removed as it is already
> >> submitted by Andrei.
> >>
> >> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> >> ---
> >> =A0net/bluetooth/l2cap_sock.c | =A0 =A05 +++--
> >> =A01 files changed, 3 insertions(+), 2 deletions(-)
> >
> > We prefer following commit log (this is the example)
> >
> > <------8<----------------------------------------------------------
> > | =A0From: Santosh Nayak <santoshprasadnayak@gmail.com>
> > |
> > | =A0Fix network to host endian conversion for L2CAP chan id.
> > |
> > | =A0Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> > |
> > | =A0---
> > | =A0 =A0 =A0 =A0 =A0* v2 Fix for null dereferenced removed as it i=
s already
> > | =A0 =A0 =A0 =A0 =A0submitted by Andrei.
> > |
> > | =A0 =A0net/bluetooth/l2cap_sock.c | =A0 =A05 +++--
> > | =A0 =A01 files changed, 3 insertions(+), 2 deletions(-)
> > |
> > <------8<----------------------------------------------------------

Best regards=20
Andrei Emeltchenko=20
