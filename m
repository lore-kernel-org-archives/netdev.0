From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Sat, 17 Oct 2015 16:41:48 -0700
Message-ID: <20151017234148.GD9038@kroah.com>
References: <1443650383.13282.10.camel@daevel.fr>
 <560D1223.3070606@googlemail.com>
 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
 <560D1C5A.3050508@googlemail.com>
 <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
 <560E2994.5020400@tomt.net>
 <560E2F7C.4040102@googlemail.com>
 <56102908.2030406@whissi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Holger =?iso-8859-1?Q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>, Andre Tomt <andre@tomt.net>,
	Eric Dumazet <edumazet@google.com>, stable@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Thomas D." <whissi@whissi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56102908.2030406@whissi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 03, 2015 at 09:14:16PM +0200, Thomas D. wrote:
> Hi,
>=20
> Holger Hoffst=E4tte wrote:
> > Greg, any chance you can drop this into the pending 4.1.10? Otherwi=
se people
> > will get another broken release.
>=20
> For me it looks like the request was too late, the patch is not inclu=
ded
> in 4.1.10. So don't forget to re-apply the patch when doing the upgra=
de.
>=20
> Greg, do you need a dedicated inclusion request for
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit=
/?id=3D83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
> in 4.1.x or is it already on your list?

Now applied, thanks.

greg k-h
