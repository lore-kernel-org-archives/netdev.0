From: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bmork@dod.no>
Subject: Re: Router stops routing after changing MAC Address
Date: Tue, 14 Mar 2006 15:16:30 +0100
Message-ID: <87pskp158h.fsf@obelix.mork.no>
References: <925A849792280C4E80C5461017A4B8A20321F2@mail733.InfraSupportEtc.com>
	<20060313100041.212cee08@localhost.localdomain>
	<Pine.LNX.4.61.0603131513380.5373@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751897AbWCNOSf@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"linux-os \(Dick Johnson\)" <linux-os@analogic.com> writes:

> Actually, it doesn't make any difference. Changing the IEEE station
> (physical) address is not an allowed procedure even though hooks are
> available in many drivers to do this.

Of course it is.  It's even required to support some obsolete
networking protocols.  You could start with
Documentation/networking/decnet.txt if you don't want to STFW


Bj=F8rn
--=20
I mean, you're always totally wrong.
