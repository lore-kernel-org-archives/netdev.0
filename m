From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.21 known regressions (v2) (for -stable team)
Date: Mon, 30 Apr 2007 14:30:57 -0700
Message-ID: <20070430143057.41ec75db@freekitty>
References: <463375E5.5040108@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-acpi@vger.kernel.org,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	Len Brown <len.brown@intel.com>,
	David Brownell <david-b@pacbell.net>,
	Jeff Mahoney <jeffm@suse.com>, reiserfs-dev@namesys.com,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	Francois SIMOND <curio@free.fr>, netdev@vger.kernel.org,
	=?UTF-8?B?SMOla2Fu?= Lindqvist <lindqvist@netstar.se>,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	=?UTF-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>,
	Thomas Meyer <thomas.mey@web.de>,
	Giorgio Lando <patroclo7@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:52357 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423687AbXD3VeV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 17:34:21 -0400
In-Reply-To: <463375E5.5040108@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Subject    : 2.6.21: sky2 "hw csum failure" problem
> References : http://lkml.org/lkml/2007/4/28/105
> Submitter  : H=C3=A5kan Lindqvist <lindqvist@netstar.se>
> Status     : unknown
>=20

This is not a "regression" it is a bug, that has shown up for
some users for quite a while, see:
 http://bugzilla.kernel.org/show_bug.cgi?id=3D7579


--=20
Stephen Hemminger <shemminger@linux-foundation.org>
