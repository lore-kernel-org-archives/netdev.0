From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 03/14] Phonet: build the net/phonet/ directory
Date: Wed, 17 Sep 2008 11:44:19 +0300
Message-ID: <200809171144.19494.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <20080916160655.GG8702@ghostprotocols.net> <20080917045224.GC7265@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org
To: "ext Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:31524 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbYIQIpu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 04:45:50 -0400
In-Reply-To: <20080917045224.GC7265@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 September 2008 07:52:25 ext Simon Horman, you wrote:
> On Tue, Sep 16, 2008 at 01:06:55PM -0300, Arnaldo Carvalho de Melo wr=
ote:
> > Em Tue, Sep 16, 2008 at 06:08:03PM +0300, R=E9mi Denis-Courmont esc=
reveu:
> > > Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com=
>
> > > ---
> > >  net/Kconfig  |    1 +
> > >  net/Makefile |    1 +
> > >  2 files changed, 2 insertions(+), 0 deletions(-)
> >
> > Can't this be combined with 2/14?
>
> Also, I think that the patches need to be re-ordered somehow.
> As things stand, applying patches (1,) 2 & 3 and setting
> CONFIG_PHONET=3Dy will try and build net/phonet/phonet.o,
> but there is no source for that object at that point.

Woops. I'll switch to 1, 4, 2+3, 5...

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
