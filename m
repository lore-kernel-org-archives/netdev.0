From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous control
Date: Sun, 8 Mar 2015 23:15:02 +0200
Message-ID: <CAJ3xEMjNKJFps7C2jsuFfnSn8pDtkCTtEhuQz8s+f=euR5=BXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Edward Cree <ecree@solarflare.com>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 23, 2015 at 11:14 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
[...]
> We discussed this during NetConf last week, and Don is correct that a
> custom sysfs interface is not the way we want to handle this.  We agreed
> upon a generic interface so that any NIC is able to turn on or off VF
> multicast promiscuous mode.

Jeff, please make sure to either respond to my comments on the V2
thread (or better) address them for the V3 post.


http://marc.info/?l=linux-netdev&m=142441852518152&w=2
http://marc.info/?l=linux-netdev&m=142441867218183&w=2

Or.
