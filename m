From: Diego Calleja <diegocg@gmail.com>
Subject: Re: 2.6.21 known regressions (v2) (for -stable team)
Date: Sat, 28 Apr 2007 21:06:49 +0200
Message-ID: <20070428210649.de34a681.diegocg@gmail.com>
References: <463375E5.5040108@googlemail.com>
	<46338C5B.4010809@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	Len Brown <len.brown@intel.com>,
	David Brownell <david-b@pacbell.net>,
	Jeff Mahoney <jeffm@suse.com>, reiserfs-dev@namesys.com,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	Francois SIMOND <curio@free.fr>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	=?ISO-8859-1?B?SOVrYW4=?= Lindqvist <lindqvist@netstar.se>,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	=?ISO-8859-1?B?RnJhbudvaXM=?= Valenduc
	<francois.valenduc@skynet.be>, Thomas Meyer <thomas.mey@web.de>,
	Giorgio Lando <patroclo7@gmail.com>,
	Dave Jones <davej@redh
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <46338C5B.4010809@m3y3r.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Sat, 28 Apr 2007 20:03:07 +0200, Thomas Meyer <thomas@m3y3r.de> escr=
ibi=F3:

> Please remove this from the regression list. This seems to be an
> userspace only problem and is not related to any kernel driver:
> amarok and/or audacious seems to repeatedly read/write to the X socke=
t:

OK - I added it just to be sure that there wasn't any dynticks regressi=
on,
it's gone now.
-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
