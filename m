From: Pavel Machek <pavel@suse.cz>
Subject: Re: zd1201 failure on sharp zaurus explained
Date: Tue, 30 May 2006 16:49:37 +0200
Message-ID: <20060530144937.GD27794@elf.ucw.cz>
References: <20060530132054.GA9780@elf.ucw.cz> <200605301611.02984.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rpurdie@rpsys.net, lenz@cs.wisc.edu,
	kernel list <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	Netdev list <netdev@vger.kernel.org>,
	Jirka Lenost Benc <jbenc@suse.cz>, pe1rxq@amsat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:3750 "EHLO amd.ucw.cz")
	by vger.kernel.org with ESMTP id S932298AbWE3OuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 10:50:23 -0400
To: Oliver Neukum <oliver@neukum.org>
Content-Disposition: inline
In-Reply-To: <200605301611.02984.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On =DAt 30-05-06 16:11:02, Oliver Neukum wrote:
> Am Dienstag, 30. Mai 2006 15:20 schrieb Pavel Machek:
> > 2) usb problem, probably. Should not usb core detect that card
> > requires too much juice and refuse to power it up?
>=20
> Does your hub correctly report whether it is plugged in?

No idea; how do I tell?

But zaurus tries to power the wlan card even if it is directly plugged
in. wlan card there comunicates with the computer but not with the
wireless part...
								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
