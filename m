From: Norbert Preining <preining@logic.at>
Subject: Re: tg3 kernel bug in 2.6.18-mm3 and 2.6.19-rc2-mm2
Date: Sun, 22 Oct 2006 01:41:07 +0200
Message-ID: <20061021234107.GA12918@gamma.logic.tuwien.ac.at>
References: <20061021132239.GA29288@gamma.logic.tuwien.ac.at> <20061021.123814.106436476.davem@davemloft.net> <20061021132239.GA29288@gamma.logic.tuwien.ac.at> <20061021100207.fdc240e0.akpm@osdl.org> <200610211918.30616.rjw@sisk.pl> <20061021132239.GA29288@gamma.logic.tuwien.ac.at> <20061021100207.fdc240e0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.logic.tuwien.ac.at ([128.130.175.20]:15586 "EHLO
	alpha.logic.tuwien.ac.at") by vger.kernel.org with ESMTP
	id S1161160AbWJUXl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 19:41:58 -0400
To: Andrew Morton <akpm@osdl.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061021.123814.106436476.davem@davemloft.net> <200610211918.30616.rjw@sisk.pl> <20061021100207.fdc240e0.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew, hi all!

On Sam, 21 Okt 2006, Andrew Morton wrote:
> Can you test 2.6.19-rc2 plus the below?

2.6.19-rc2	works
2.6.19-rc2+patch does not work

So it is this patch.

hw:
Acer TravelMate 3012WMi
03:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5789 Gigab=
it Ethernet PCI Express (rev 11)

If you need dmesg, .config, something else, no problem.

Best wishes

Norbert

-----------------------------------------------------------------------=
--------
Dr. Norbert Preining <preining@logic.at>                    Universit=E0=
 di Siena
Debian Developer <preining@debian.org>                         Debian T=
eX Group
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 0=
9C5 B094
-----------------------------------------------------------------------=
--------
DITHERINGTON (n)
Sudden access to panic experienced by one who realises that he is
being drawn inexorably into a clabby (q.v.) conversion, i.e. one he
has no hope of enjoying, benefiting from or understanding.
			--- Douglas Adams, The Meaning of Liff
