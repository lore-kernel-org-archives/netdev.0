From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: add device IDs for Dell 5804
 (Novatel E371) WWAN card
Date: Wed, 08 May 2013 12:08:50 -0700 (PDT)
Message-ID: <20130508.120850.755474428060131481.davem@davemloft.net>
References: <1367874878.31762.0.camel@dcbw.foobar.com>
	<1367875057.31762.3.camel@dcbw.foobar.com>
	<87li7r6bx1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, netdev@vger.kernel.org, stable@vger.kernel.org,
	dagofthedofg@gmail.com
To: bjorn@mork.no
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87li7r6bx1.fsf@nemi.mork.no>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 06 May 2013 23:22:50 +0200

> Dan Williams <dcbw@redhat.com> writes:
>=20
>> A rebranded Novatel E371 for AT&T's LTE bands.  qmi_wwan should driv=
e this
>> device, while cdc_ether should ignore it.  Even though the USB descr=
iptors
>> are plain CDC-ETHER that USB interface is a QMI interface.
>>
>> Cc: <stable@vger.kernel.org>
>> Signed-off-by: Dan Williams <dcbw@redhat.com>
>> ---
>>  drivers/net/usb/cdc_ether.c | 7 +++++++
>>  drivers/net/usb/qmi_wwan.c  | 7 +++++++
>>  2 files changed, 14 insertions(+)
>=20
> Acked-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
