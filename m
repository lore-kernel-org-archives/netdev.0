From: Dan Williams <dcbw@redhat.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 08 Dec 2014 17:42:17 -0600
Message-ID: <1418082137.31640.14.camel@dcbw.local>
References: <201411271506.20457@pali> <201412082036.14609@pali>
	 <1418079067.31640.13.camel@dcbw.local> <201412090023.18173@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261AbaLHXsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 18:48:54 -0500
In-Reply-To: <201412090023.18173@pali>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 00:23 +0100, Pali Roh=C3=A1r wrote:
> On Monday 08 December 2014 23:51:07 Dan Williams wrote:
> > Is the CAL data format generic to all wl1251 devices?  Or is
> > the stuff in the CAL partition Nokia-specific?
> >=20
>=20
> Specific for Nokia devices.

Ok, but then something must transform that data into a format that the
wl1251 chip can consume, correct?  What do other wl1251 platforms do to
retrieve this information and set regulatory region?

Dan
