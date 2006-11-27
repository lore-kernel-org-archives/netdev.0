From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Mon, 27 Nov 2006 11:43:46 -0800
Message-ID: <456B3FF2.3010908@redhat.com>
References: <11641265982190@2ka.mipt.ru> <456621AC.7000009@redhat.com> <20061124120531.GC32545@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758538AbWK0To4@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124120531.GC32545@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> It _IS_ how previous interface worked.
>=20
> 	EXACTLY!

No, the old interface committed everything not only up to a given index=
=2E=20
  This is the huge difference which makes or breaks it.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
