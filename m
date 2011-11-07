From: Alexander Kolesen <kolesen.a@gmail.com>
Subject: Re: ixgbe: compilation failed if CONFIG_PCI_IOV isn't set
Date: Mon, 7 Nov 2011 15:46:45 +0300
Message-ID: <20111107124641.GB28044@vaio>
References: <20111106000819.GC12157@vaio>
 <1320549540.5386.29.camel@jtkirshe-mobl>
 <CAJZOPZJrrSFr_WvXWpd9xH1ioa9kmg+KX8Xzx940DB=_V4W6EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Li, Sibai" <sibai.li@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.wargaming.net ([213.252.131.228]:46650 "EHLO
	mail.wargaming.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab1KGMq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 07:46:56 -0500
Content-Disposition: inline
In-Reply-To: <CAJZOPZJrrSFr_WvXWpd9xH1ioa9kmg+KX8Xzx940DB=_V4W6EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, Nov 6, 2011 at 5:18 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > Was with the latest kernel from David Miller's net.gt tree? =A0I ju=
st ask
> > because I just pushed a patch (a couple of days ago) to resolve
> > compilation errors when CONFIG_PCI_IOV is not enabled by Greg Rose.
>=20
> In my case it was with Linus tree from github
>=20
> Or.
It was with Linus tree, but David Miller's net.gt alsa has this issue.
