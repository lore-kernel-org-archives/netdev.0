From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: in kernel 2.6.x, tun/tap nic supports vlan packets
Date: Wed, 23 Apr 2014 12:41:49 +0100
Message-ID: <1398253309.7767.136.camel@deadeye.wl.decadent.org.uk>
References: <534F4C1E.1000006@gmail.com> <20140417050228.GC8243@1wt.eu>
	 <1398189237.7767.77.camel@deadeye.wl.decadent.org.uk>
	 <53577036.2040307@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-22v6WCIoSPmTGYbBNNgO"
Cc: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, joe@perches.com, julia.lawall@lip6.fr,
	dingtianhong@huawei.com, linux-kernel@vger.kernel.org,
	jasowang@redhat.com, mst@redhat.com,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53577036.2040307@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-22v6WCIoSPmTGYbBNNgO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-23 at 15:48 +0800, zhuyj wrote:
> On 04/23/2014 01:53 AM, Ben Hutchings wrote:
[...]
> > For what it's worth, I would recommend against applying this.  I don't
> > think even Red Hat has backported the VLAN changes, and they have been
> > quite aggressive about backporting features to RHEL 6.
> If we do not merge these patches, maybe RHEL 6 can not make tap driver=
=20
> support vlan well.

RHEL 6 isn't based on 2.6.32.y, they do all their own backporting.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-22v6WCIoSPmTGYbBNNgO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1em/ee/yOyVhhEJAQpRtQ/5AYv96is6qtCzv/jbI9cRIVACT+ZWbV1O
wLoDJvykX7oBcL9VhBPNdvqwspcfq/9ZtSW4N90g5zi2oNPHUL9GzJFoSthtAXTn
EJKZkgte8fUWtowJBgyrLXE83XRuLTF39YIeGazQd8nx8U558Q/3pwJrg+35zjdV
8bFQXrBzQGLZFpRGAjvYcKMqLSVXLoSDG/VBbv4QNTT2lQ0y5EA34vBySJax9cEv
akna6Ea72r1xL9Zyv5kqutLjkFUouSX2CwrkK7BauaR9wffzyYaB8oaees3CCsiv
rRMsrNxzFfZB+f6uVyskH27pRji9eYoVcXRS+BnPUJS7QHv8cggMiZh7Xmo/sF4t
4eWBysYP6Ywmfhoop/eMYXiwrw6b+B2y2M83pjkABV252KpmGGB0mSt3yTXYt0OS
YpvgXYYaIn7qm2MzeWtGdPSB1vKkJFjaf5WXQIxDnF0we2UcbZHb74EctYnS+Rc3
ZJe7KxugPxwNjPRikA+seT5c/VcD2YanDzJA/YKXmgcW6EO8i8au6w/tMZeupnpq
Yay4In9NsA1zHPTRcKMG59aw2ypcZEw9h5Kn44xijt/okcJeBLywfc6YrBshUOrk
ICFU3T7hQueJErK37HtbdZIwlaHmIbEr+eYWEWvqiVy5dh+Qda7CvOHRCc6zQKUj
MAEBXOjj8WQ=
=RAEV
-----END PGP SIGNATURE-----

--=-22v6WCIoSPmTGYbBNNgO--
