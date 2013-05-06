From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel E371) WWAN card
Date: Mon, 06 May 2013 23:22:50 +0200
Message-ID: <87li7r6bx1.fsf@nemi.mork.no>
References: <1367874878.31762.0.camel@dcbw.foobar.com>
	<1367875057.31762.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	dagofthedofg@gmail.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1367875057.31762.3.camel@dcbw.foobar.com> (Dan Williams's
	message of "Mon, 06 May 2013 16:17:37 -0500")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw@redhat.com> writes:

> A rebranded Novatel E371 for AT&T's LTE bands.  qmi_wwan should drive=
 this
> device, while cdc_ether should ignore it.  Even though the USB descri=
ptors
> are plain CDC-ETHER that USB interface is a QMI interface.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
>  drivers/net/usb/cdc_ether.c | 7 +++++++
>  drivers/net/usb/qmi_wwan.c  | 7 +++++++
>  2 files changed, 14 insertions(+)

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
