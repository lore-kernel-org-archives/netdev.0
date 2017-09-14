From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [LPC] 2nd RDMA Mini-Summit Schedule
Date: Thu, 14 Sep 2017 19:48:35 +0300
Message-ID: <20170914164835.GB3405@mtr-leonro.local>
References: <20170907051805.GA19175@mtr-leonro.local>
 <20170913130216.GT3405@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="i/CQJCAqWP/GQJtX"
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
In-Reply-To: <20170913130216.GT3405-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--i/CQJCAqWP/GQJtX
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 13, 2017 at 04:02:16PM +0300, Leon Romanovsky wrote:
> On Thu, Sep 07, 2017 at 08:18:05AM +0300, Leon Romanovsky wrote:
> > Hi,
> >
> > We're happy to announce schedule of the 2nd RDMA mini-summit, which wil=
l be
> > held as part of coming Linux Plumbers Conference 2017.
> >
> > During the conference, we will have two sessions: main track session and
> > round table session.
> >
> > First session will be held on Thursday, September 14, 2017 from 9:30am =
=E2=80=93 12:30pm
> > with the topics relevant for the wider audience.
> >
> > In the second session, we  will focus on more face to face discussions =
in round
> > table format and it will be scheduled a little bit later once we will g=
et meeting
> > room.
>
> UPDATE:
> The round table will take place at 2:00pm on Thursday, September 14,
> 2017 in one of the speakers's suites (3rd floor, near Georgia I/II).
>
> Thanks

UPDATE:
RDMA round table will be held at Platinum Ballroom J. from 2:00pm till 6:30=
pm.

Thanks

>
> >
> > -----------------------------------------------------------------------=
----------------
> > FIRST SESSION:
> > -----------------------------------------------------------------------=
----------------
> >  * Backporting issues with multi-subsystem device (RDMA + netdev + more=
) by Don Dutile
> >    - More and more devices in RDMA are dependent on netdev as well as o=
ther
> >      subsystems -- target, NFS, scsi, block, cgroups, SELinux.... Can w=
e make
> >      backporting task for distro people easier?
> >  * kABI Update by Matan Barak
> >    - Going forward with a flexible and secure RDMA kABI
> >  * System Boot and RDMA by Jason Gunthrope
> >    - Discuss boot-time issues with the RDMA subsystem
> >  * Paravirtual RDMA device by Marcel Apfelbaum and Yuval Shaia
> >    - QEMU's limited RDMA support leaves it behind other modern hypervis=
ors.
> >      Marcel and Yuval will present the implementation of an emulated RD=
MA device,
> >      analyze its performance and usability, and finally talk about futu=
re plans
> >      for a possible virtio-rdma device.
> >   * TX Flow Steering for IPsec by Liran Liss (pending time slot)
> >    - The IPsec protocol provides both encryption and authentication for=
 IP
> >      protocol packets. Users of the raw ethernet QP that send/receive I=
Psec packets
> >      could benefit from the IPsec crypto offloads capabilities that are
> >      available in recent NICs.
> >   * OpenFabrics Alliance - Status and New Directions by Jason Gunthrope
> >   * BOF - Open Discussion
> >    - Open discussion with the community lead by Leon Romanovsky, Jason =
Gunthorpe,
> >      Christoph Lameter and Dennis Dalessandro
> >
> > -----------------------------------------------------------------------=
----------------
> > ROUND TABLE SESSION:
> > -----------------------------------------------------------------------=
----------------
> > Possible list, bring your own topics:
> >  * RDMA and ULPs
> >  * Verbs testing suite
> >  * RDMA netlink and RDMAtool future plans
> >  * RDMA and the Linux IP stack
> >  * Infrastructure issues with Travis CI
> >  * Infrastructure gaps with rdma-core
> >  * Packaging as part of CI for rdma-core.
> >  * ....
> >
> > See you next week at Linux Plumber Conference 2017.
> >
> > Thanks
>
>



--i/CQJCAqWP/GQJtX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlm6suMACgkQ5GN7iDZy
WKcBgA/9EzLxzIn9a2SJDwIC2ZlQGhxLXSP+Susi7eR4zJJHIi++o+PycrvvU0LJ
XT4fMzdkfkjCoBndRWAVRjoXlLSZv72S80d6vKS+mMGr5XTiNfMqeIAYVhnkiDBj
fadl4VG6I+TgS6XVR80H4cSIckqFKdhL5KbCRKqg11iEral6og6cb/+qVFwiwvdr
atcms4ZhO++1WCBqpNNBdvrGYBgARkgFInPUSWfvkd/+U3YOm2evOokmf2QM7yKv
SGT9oQwgCYKTtvidH83qVylES/SxRDMDWw/zt6jih+3rg/i6iNjnBTRBhIvZqb22
L2XFtqT11qIeALlBmuxDjTgVQs7UF8qi1B1xf0DQqK5/uY5gYmCABNJfHYftpsS5
j+HAEtY1a867FUxbN5RoygEdyPQgMu58aGM/04ZEc5kWu02F8tKU1sUkYIcmd8WI
CWrZsoE7V/f2XgYOUDveUoaA0tmXsaXTlWxLeH7ceMnZ1BlLvg1usuAyzGCFmw+Q
Ms1xbGxX7aYRYgjpsxBmcrlwkQPuCKSVTDQty1HgCjmYqZc0ELrd0TO6VvokJ+jV
XWqmrAN1xFSyB8v3Qy5dBe/T79Ywpp/xCexT9DHWNzaMau9xY+qrMw+hNt1APeJK
e5X12A9doEez6X2da7uB+aOta66VZnpCIujZFWuYFyuJgVYnjTk=
=DdUW
-----END PGP SIGNATURE-----

--i/CQJCAqWP/GQJtX--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
