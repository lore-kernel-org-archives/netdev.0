From: Sebastian Reichel <sre@kernel.org>
Subject: Re: [PATCH net-next v2 7/9] net: use core MTU range checking in misc
 drivers
Date: Fri, 21 Oct 2016 18:22:28 +0200
Message-ID: <20161021162228.5lllrnsbegxgf3lu@earth>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
 <20161020175524.6184-8-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="eeqo55dra4cvgby7"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org,
        Stefan Richter <stefanr@s5r6.in-berlin.de>,
        Faisal Latif <faisal.latif@intel.com>,
        Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        Chaitra P B <chaitra.basappa@broadcom.com>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani@broadcom.com>,
        MPT-FusionLinux.pdl@broadcom.com, Felipe Balbi <balbi@kernel.org>,
        Arvid Brodin <arvid.brodin@alten.se>,
        Remi Denis-Courmont <courmisch@gmail.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161020175524.6184-8-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--eeqo55dra4cvgby7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Thu, Oct 20, 2016 at 01:55:22PM -0400, Jarod Wilson wrote:
> hsi/clients/ssi_protocol:
> - use core MTU range checking
> - remove now redundant ssip_pn_set_mtu

Acked-By: Sebastian Reichel <sre@kernel.org>

-- Sebastian

--eeqo55dra4cvgby7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYCkDBAAoJENju1/PIO/qa9mYQAJESHC4204kwddPXQrq/mw6b
vPGsFsMUXrpfx7Sq25Aaf9GB1ubkqznDKjW6Wfo6oGzaWJ1hfvGrJzP5xHbOJPbf
Mi3mHd3+Psj6H1uv84HJP951RDw+99EvT8HzxSshPFVi62Xzffw07zLO2qgX4LIM
ZKTuoR1nyIDcd0AGFbh9JGKtrG6gnAeAL4xowipUyS5vM/d6vJd9L0qO2Ky6ahpp
/NBPjVVWYIh04fU2AmWmXBIeq49jsEL4sRAvFdLFJijZtGdGyq/FL+RaG6x8hZAR
1RZIkqPFV9FxcxMQweh7xvgXhpwQ+Y8G4T0KXqYoIIcplHD6u86FRIDvr+06HR1x
9tjIxj2jkbC4nHlJXZVK6qZc08+qnhBzs2US8H0BB0sD2W79paLgjj7wGpP99zKX
Dva9z4NYi/HgQQ8HiU12ImV5tIGXvqjoNGLggPiQg9FV9kKubZTXQQuaqyphbEc6
4+EvsSFAf5bl6cGuYG/f2ibMA9Pe2WkSRFEyJN62ARU6sItK6SwP/BmRJFqa8BCl
el8ma5tLMbQQdwhE3mUmfInRpuOjX3gueLpHrhvjeR86HnSE2gIcErnAC8lzltUw
PJQxDOSP+dallMc5bDqFphPbHzZ7if4687U3M8yrvz3ew+NuyeaDeWWvFLrV4Hf9
UHu/BrnSZaN7XZSqCGW7
=ui/h
-----END PGP SIGNATURE-----

--eeqo55dra4cvgby7--
