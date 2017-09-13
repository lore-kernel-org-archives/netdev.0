From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [LPC] 2nd RDMA Mini-Summit Schedule
Date: Wed, 13 Sep 2017 16:02:16 +0300
Message-ID: <20170913130216.GT3405@mtr-leonro.local>
References: <20170907051805.GA19175@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="D6z0c4W1rkZNF4Vu"
Cc: linux-netdev <netdev@vger.kernel.org>,
        NVME mailing list <linux-nvme@lists.infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        Knut Omang <knut.omang@oracle.com>,
        Christoph Lameter <cl@linux.com>,
        Don Dutile <ddutile@redhat.com>,
        Liran Liss <liranl@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Yuval Shaia <yuval.shaia@oracle.com>,
        Marcel Apfelbaum <marcel@redhat.com>, lwn@lwn.net
To: RDMA mailing list <linux-rdma@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43132 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751173AbdIMNCb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 09:02:31 -0400
Content-Disposition: inline
In-Reply-To: <20170907051805.GA19175@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--D6z0c4W1rkZNF4Vu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 07, 2017 at 08:18:05AM +0300, Leon Romanovsky wrote:
> Hi,
>
> We're happy to announce schedule of the 2nd RDMA mini-summit, which will =
be
> held as part of coming Linux Plumbers Conference 2017.
>
> During the conference, we will have two sessions: main track session and
> round table session.
>
> First session will be held on Thursday, September 14, 2017 from 9:30am =
=E2=80=93 12:30pm
> with the topics relevant for the wider audience.
>
> In the second session, we  will focus on more face to face discussions in=
 round
> table format and it will be scheduled a little bit later once we will get=
 meeting
> room.

UPDATE:
The round table will take place at 2:00pm on Thursday, September 14,
2017 in one of the speakers's suites (3rd floor, near Georgia I/II).

Thanks

>
> -------------------------------------------------------------------------=
--------------
> FIRST SESSION:
> -------------------------------------------------------------------------=
--------------
>  * Backporting issues with multi-subsystem device (RDMA + netdev + more) =
by Don Dutile
>    - More and more devices in RDMA are dependent on netdev as well as oth=
er
>      subsystems -- target, NFS, scsi, block, cgroups, SELinux.... Can we =
make
>      backporting task for distro people easier?
>  * kABI Update by Matan Barak
>    - Going forward with a flexible and secure RDMA kABI
>  * System Boot and RDMA by Jason Gunthrope
>    - Discuss boot-time issues with the RDMA subsystem
>  * Paravirtual RDMA device by Marcel Apfelbaum and Yuval Shaia
>    - QEMU's limited RDMA support leaves it behind other modern hypervisor=
s.
>      Marcel and Yuval will present the implementation of an emulated RDMA=
 device,
>      analyze its performance and usability, and finally talk about future=
 plans
>      for a possible virtio-rdma device.
>   * TX Flow Steering for IPsec by Liran Liss (pending time slot)
>    - The IPsec protocol provides both encryption and authentication for IP
>      protocol packets. Users of the raw ethernet QP that send/receive IPs=
ec packets
>      could benefit from the IPsec crypto offloads capabilities that are
>      available in recent NICs.
>   * OpenFabrics Alliance - Status and New Directions by Jason Gunthrope
>   * BOF - Open Discussion
>    - Open discussion with the community lead by Leon Romanovsky, Jason Gu=
nthorpe,
>      Christoph Lameter and Dennis Dalessandro
>
> -------------------------------------------------------------------------=
--------------
> ROUND TABLE SESSION:
> -------------------------------------------------------------------------=
--------------
> Possible list, bring your own topics:
>  * RDMA and ULPs
>  * Verbs testing suite
>  * RDMA netlink and RDMAtool future plans
>  * RDMA and the Linux IP stack
>  * Infrastructure issues with Travis CI
>  * Infrastructure gaps with rdma-core
>  * Packaging as part of CI for rdma-core.
>  * ....
>
> See you next week at Linux Plumber Conference 2017.
>
> Thanks



--D6z0c4W1rkZNF4Vu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlm5LFgACgkQ5GN7iDZy
WKdyAxAAggf6221aV5t9f5owz1cJvlyvBuZ+muCzHucs6OASDz24Ybyxe+1qhDaT
5ROheTQGkVJiFRiSPu+hJ48J50bkSQAnEVmq9NjWRi/ap8MO2yfH/ulLXF9qumuU
RcVdNvCWyP91bL04joImPIVM5NYoj7pOV79dJ3SQt4hj14ruy3FPHKiL8Kk8uiQ4
Z1HfLYz5UiLs9cjOYMXJky5/TKWunY1dOoBhnlEdsz1jQokzL2B7Fawct/2B3vyZ
+gxFOxskKeBiKXH7cjQ04gHYW0UDPSwPc0Qm0bQBmGvR5n+Fkzj9BcC5SK8fMB9I
M2NHLaB8BRsglSov3Em3NwwaVSzxTKtap0qQV0W1JMToqKIjIjpdsJlAc2DiWDpa
oL6vX4/xkClfvsLA+bJS6IiKkzjVcBPd3xi7kXPWV931CpWVjciW9O7cGc5nW//T
zFXKiZEiqmQ1qx45bLmNxtFmBGos48tAxmZjTYsAKEnqtt35YCRE0JYEXf/3es4N
Bxz28iSF8mCnBZ81ftY7WFkPCc93p4LLhAx7hni6WOAMSZY6gid4Z94a6UNR3Eza
lKfVV+ELB6ovM+qMKJfxN7oB28h2ZSt1/UFAHpxUNq2j1Xtc9jPNs2BJqF9SP3bK
Rxek4z+qlNX3nRIWPlmm8vmU2SZq9/TNeOy6g0+vS8WuG/vbjQE=
=EBDB
-----END PGP SIGNATURE-----

--D6z0c4W1rkZNF4Vu--
