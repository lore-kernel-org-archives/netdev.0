From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: ixgbe: compilation failed if CONFIG_PCI_IOV isn't set
Date: Mon, 7 Nov 2011 08:47:09 -0800
Message-ID: <43F901BD926A4E43B106BF17856F075501A1CCA39D@orsmsx508.amr.corp.intel.com>
References: <20111106000819.GC12157@vaio>
 <1320549540.5386.29.camel@jtkirshe-mobl>
 <CAJZOPZJrrSFr_WvXWpd9xH1ioa9kmg+KX8Xzx940DB=_V4W6EQ@mail.gmail.com>
 <20111107124641.GB28044@vaio>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Li, Sibai" <sibai.li@intel.com>
To: Alexander Kolesen <kolesen.a@gmail.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:48393 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932668Ab1KGQrT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 11:47:19 -0500
In-Reply-To: <20111107124641.GB28044@vaio>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Alexander Kolesen [mailto:kolesen.a@gmail.com]
> Sent: Monday, November 07, 2011 4:47 AM
> To: Or Gerlitz
> Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org; Rose, Gregory V; Li, =
Sibai
> Subject: Re: ixgbe: compilation failed if CONFIG_PCI_IOV isn't set
>=20
> > On Sun, Nov 6, 2011 at 5:18 AM, Jeff Kirsher
> > <jeffrey.t.kirsher@intel.com> wrote:
> > > Was with the latest kernel from David Miller's net.gt tree? =A0I =
just
> ask
> > > because I just pushed a patch (a couple of days ago) to resolve
> > > compilation errors when CONFIG_PCI_IOV is not enabled by Greg Ros=
e.
> >
> > In my case it was with Linus tree from github
> >
> > Or.
> It was with Linus tree, but David Miller's net.gt alsa has this issue=
=2E

Yeah, I'll have it fixed soon.  My apologies.

- Greg
