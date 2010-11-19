From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.37-rc2-git4: Reported regressions from 2.6.36
Date: Fri, 19 Nov 2010 21:37:02 +0100
Message-ID: <201011192137.02426.rjw@sisk.pl>
References: <sKkKYVppECN.A.KhC.Phb5MB@chimera> <AANLkTimBJAKUEe3POB49DFSxqZzQAd03e_3Rn-0mP4wY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Alex Deucher <alexdeucher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:38235 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755936Ab0KSUhp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 15:37:45 -0500
In-Reply-To: <AANLkTimBJAKUEe3POB49DFSxqZzQAd03e_3Rn-0mP4wY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, November 19, 2010, Alex Deucher wrote:
> On Thu, Nov 18, 2010 at 6:23 PM, Rafael J. Wysocki <rjw@sisk.pl> wrot=
e:
> > This message contains a list of some regressions from 2.6.36,
> > for which there are no fixes in the mainline known to the tracking =
team.
> > If any of them have been fixed already, please let us know.
> >
> > If you know of any other unresolved regressions from 2.6.36, please=
 let us
> > know either and we'll add them to the list.  Also, please let us kn=
ow
> > if any of the entries below are invalid.
> >
> > Each entry from the list will be sent additionally in an automatic =
reply
> > to this message with CCs to the people involved in reporting and ha=
ndling
> > the issue.
> >
> >
> > Listed regressions statistics:
> >
> >  Date          Total  Pending  Unresolved
> >  ----------------------------------------
> >  2010-11-19       39       29          25
> >
> >
> > Unresolved regressions
> > ----------------------
> >
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D2322=
2
> > Subject         : 2.6.36 radeon KMS: [drm] Cannot find any crtc or =
sizes
> > Submitter       : J=E1n Bedn=E1r <jan.bednar@gmail.com>
> > Date            : 2010-11-18 15:33 (1 days old)
> >
>=20
> I've added a fix to that bug.

It doesn't seem to have helped, though.

Thanks,
Rafael
