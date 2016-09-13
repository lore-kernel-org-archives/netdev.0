From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Tue, 13 Sep 2016 20:18:38 +0000
Message-ID: <69DF2AA5-F813-476F-BB10-B3CB35656512@intel.com>
References: <20160913171950.GC32643@uranus>
 <1473791620.14269.2.camel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
        boundary="Apple-Mail=_D3F52B2A-CA3C-4D7A-AA3B-4258D14F25A1";
        protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "avagin@openvz.org" <avagin@openvz.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
To: Greg <gvrose8192@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473791620.14269.2.camel@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_D3F52B2A-CA3C-4D7A-AA3B-4258D14F25A1
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Greg <gvrose8192@gmail.com> wrote:

> Someday Linux will be a modern OS that just includes IPV6 and forces a
> config option to NOT have it.
>
> That'll be great.  All the IS_ENABLED_(CONFIG_IPV6) scattered everywhere
> is nuts.
>
> </editorial comment>

Better wait until everyone at least *has* IPv6! I have yet to have IPv6  
deployed on any of my employer's networks or get IPv6 service from any ISP  
at my home. When I was at Apple in the 90's I was told that Apple needed  
IPv6 by next year or "we were dead". Well Apple nearly died, but IPv6 had  
nothing to do with that! And I still haven't experienced an IPv6  
deployment! Yeah, I have run it a bit point-to-point to resolve technical  
issues, but that isn't a "deployment" and not very interesting.

As much as we would like things to move faster, much of the world just  
doesn't. Witness the e1000 discussion today for example. Hardware doesn't  
vanish overnight, and I know that my ISP has a network full of CPE that  
doesn't do IPv6, so I'm not expecting their status to change any time soon.

It would be great though.
</pipedream>

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_D3F52B2A-CA3C-4D7A-AA3B-4258D14F25A1
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJX2F8dAAoJEDwO/+eO4+5uHQsQAIu0DngyF5xEouJZLBW0bH1n
q9wOf/+FyjxyHIUhNm6lWLFdylF34/e6HvUIcFuFOl6BPDHfAOWokgZ/INvfk+ci
/C+0ItbPERIFVZ9GvQCCgkK1vw2xTZmPNV//sClTuS2ToSPN/2U3m2bW/QdbQiI8
4JGoaR2duRNlkP4+NVbP2eLv2cMd4QjFXoYUNYkG78H9C5oKZvT75ZLONk/ro9SZ
Ch+LnVCvkjrM9s0fwuc58B/EAyIZLOkuiJbUYSyFK7GuBwoLM8ZCCcDcDl58CNs6
7fYwFL/LtP00DkU8bj71DnFrpNmPlapvEnY654+6kqVLqZR6K5JhlQi9w3jUPcts
sv/rPzudEjUo97Cy4hDuAPwuDs81LwosslQzkXsriFzO+Ez4Xo4bEzjNEdCzlMv1
a/9NME9swQ/xpXgoR+4GRid0Wiyy3hwwuwlXRYtZhsCPA6+xg5R86T0w19oTOqpP
E60GkivD3/Tnel6Sh7rzD9FMMIwwd5dMddMxzkxevYUQPMGOveVStTPhUOip8drm
GLkOFsLH9qz/Vzlh5FbwfSQXS/cUbO+ba3MKWgtSidoFNdvDOyuTHwW125M+Reqm
gx8l372o3snSxEE36FhEt9gciBF14FlyppdQHZ+sQXf6Cfqr6f/TdyCHVwnzii84
mo5wxRZ2+0URkKEO01ZH
=k07m
-----END PGP SIGNATURE-----

--Apple-Mail=_D3F52B2A-CA3C-4D7A-AA3B-4258D14F25A1--
