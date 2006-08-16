From: Bodo Eggert <7eggert@elstempel.de>
Subject: Re: bonding: cannot remove certain named devices
Date: Wed, 16 Aug 2006 02:02:03 +0200
Message-ID: <E1GD8rX-0001cA-CV@be1.lrz>
References: <6Kd5j-3Y7-3@gated-at.bofh.it> <6KdRL-5xP-7@gated-at.bofh.it> <6Ke1p-5N8-7@gated-at.bofh.it> <6KekO-6u0-25@gated-at.bofh.it> <6KeXv-7qe-17@gated-at.bofh.it> <6KfTz-OX-11@gated-at.bofh.it> <6KfTA-OX-15@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:53999 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750703AbWHPAFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 20:05:49 -0400
To: Stephen Hemminger <shemminger@osdl.org>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Bill Nottingham <notting@redhat.com>,
	 ?missing closing '"' in token?"Williams",
	Mitch A <mitch.a.williams@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:

> IMHO idiots who put space's in filenames should be ignored. As long a=
s the
> bonding code doesn't throw a fatal error, it has every right to retur=
n
> "No such device" to the fool.

Maybe you should limit device names to eight uppercase characters and u=
p to
three characters extension, too. NOT! There is no reason to artificiall=
y
impose limitations on device names, so don't do that.
--=20
Ich danke GMX daf=FCr, die Verwendung meiner Adressen mittels per SPF
verbreiteten L=FCgen zu sabotieren.

http://david.woodhou.se/why-not-spf.html
