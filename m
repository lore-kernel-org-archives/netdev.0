From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [LPC] 2nd RDMA Mini-Summit Schedule
Date: Thu, 7 Sep 2017 08:18:05 +0300
Message-ID: <20170907051805.GA19175@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Cc: linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        NVME mailing list <linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Knut Omang <knut.omang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
        Don Dutile <ddutile-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tzahi Oved <tzahio-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Marcel Apfelbaum <marcel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, lwn-T1hC0tSOHrs@public.gmane.org
To: RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

We're happy to announce schedule of the 2nd RDMA mini-summit, which will be
held as part of coming Linux Plumbers Conference 2017.

During the conference, we will have two sessions: main track session and
round table session.

First session will be held on Thursday, September 14, 2017 from 9:30am =E2=
=80=93 12:30pm
with the topics relevant for the wider audience.

In the second session, we  will focus on more face to face discussions in r=
ound
table format and it will be scheduled a little bit later once we will get m=
eeting
room.

---------------------------------------------------------------------------=
------------
FIRST SESSION:
---------------------------------------------------------------------------=
------------
 * Backporting issues with multi-subsystem device (RDMA + netdev + more) by=
 Don Dutile
   - More and more devices in RDMA are dependent on netdev as well as other
     subsystems -- target, NFS, scsi, block, cgroups, SELinux.... Can we ma=
ke
     backporting task for distro people easier?
 * kABI Update by Matan Barak
   - Going forward with a flexible and secure RDMA kABI
 * System Boot and RDMA by Jason Gunthrope
   - Discuss boot-time issues with the RDMA subsystem
 * Paravirtual RDMA device by Marcel Apfelbaum and Yuval Shaia
   - QEMU's limited RDMA support leaves it behind other modern hypervisors.
     Marcel and Yuval will present the implementation of an emulated RDMA d=
evice,
     analyze its performance and usability, and finally talk about future p=
lans
     for a possible virtio-rdma device.
  * TX Flow Steering for IPsec by Liran Liss (pending time slot)
   - The IPsec protocol provides both encryption and authentication for IP
     protocol packets. Users of the raw ethernet QP that send/receive IPsec=
 packets
     could benefit from the IPsec crypto offloads capabilities that are
     available in recent NICs.
  * OpenFabrics Alliance - Status and New Directions by Jason Gunthrope
  * BOF - Open Discussion
   - Open discussion with the community lead by Leon Romanovsky, Jason Gunt=
horpe,
     Christoph Lameter and Dennis Dalessandro

---------------------------------------------------------------------------=
------------
ROUND TABLE SESSION:
---------------------------------------------------------------------------=
------------
Possible list, bring your own topics:
 * RDMA and ULPs
 * Verbs testing suite
 * RDMA netlink and RDMAtool future plans
 * RDMA and the Linux IP stack
 * Infrastructure issues with Travis CI
 * Infrastructure gaps with rdma-core
 * Packaging as part of CI for rdma-core.
 * ....

See you next week at Linux Plumber Conference 2017.

Thanks

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmw1nwACgkQ5GN7iDZy
WKeH2RAAjtJ0ox8StXoEnWfRFoXfhclUnTTX6c0eRMyZ6+EToSXtfRNq7YgtuyAw
ScxNvWtLxP51ftia9VB2I2mS/G8yUfgppRL3mC9Xp2qIub2yoQRry1qMiThcDzyz
uxv6tHvHNoCJoXXoh9sAqZgyRU2jQGsrJwcVDRIbVrqnZ42jd+0tB8ZZNEYEThEV
60iI7SEvyCtWXjtE49F5cwDd7fnygIzG/oeplENcvx4/ugUmf5/MMODNIHSyyJpG
lc3DHMHRT9ycgp8daRyfnZNhqy27luP3PGIfJPlHVFpD/1TpC/AzfwXaFgWL0UYE
JfTUOj5C7ku6wKE+ZO16Y9yC6LZgQ7QhdhySQvTesvhq0+emKqv68dVuGSD5HhHr
4KV8slvV+ZAHmzmAsG7uuTJPbNCLJueKBxs+GrXAzfXwOKK0IXTmHxzny8xArBvM
msHDtX5H2EJdScckew0UkGisP9ngzomr28H+IH7oRKrpSwBqc2nJ+y98V/ZDIj48
MlCK0QEqA1jPMyWzJZTYdnpMwTxhvFHl7LIfPczrg0IWKjyW4fAFjI51wVNEnq5S
PnmTHe8IPi27eXerJV8usOT21otpw/iAnW3mpqdhDe5E1VkBsgwuvSSe+C1amnbt
0pgTF443+jvZ4Vlez+fZgCCQe1x1tZGGkQlbw0jMmvU1S1LeLl4=
=+YCE
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
