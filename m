From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Sun, 7 May 2017 09:14:24 +0300
Message-ID: <20170507061424.GJ22833@mtr-leonro.local>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
 <20170506104047.GC2017@nanopsycho>
 <1494081623.3228.1.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="eGyD7iWN192kf2IJ"
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ram.amrani@cavium.com" <ram.amrani@cavium.com>,
        "sagi@grimberg.me" <sagi@grimberg.me>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "hch@lst.de" <hch@lst.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0055.outbound.protection.outlook.com ([104.47.1.55]:52160
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753805AbdEGVqa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 7 May 2017 17:46:30 -0400
Content-Disposition: inline
In-Reply-To: <1494081623.3228.1.camel@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--eGyD7iWN192kf2IJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 06, 2017 at 02:40:24PM +0000, Bart Van Assche wrote:
> On Sat, 2017-05-06 at 12:40 +0200, Jiri Pirko wrote:
> > Thu, May 04, 2017 at 08:10:54PM CEST, Bart.VanAssche@sandisk.com wrote:
> > > On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > > > Following our discussion both in mailing list [1] and at the LPC 2016 [2],
> > > > we would like to propose this RDMA tool to be part of iproute2 package
> > > > and finally improve this situation.
> > >
> > > Although I really appreciate your work: can you clarify why you would like to
> > > add *RDMA* functionality to an *IP routing* tool? I haven't found any motivation
> > > for adding RDMA functionality to iproute2 in [1].
> >
> > Bart, please realize that iproute2 is much more than "*IP routing* tool".
> > I understand you got confused by the name. Please see sources. Your comment
> > is totally pointless...
>
> I asked for a clarification that should have been in the cover letter but that
> was missing from that cover letter. So I think that was the right thing to do
> instead of pointless. BTW, can you explain why you are using an e-mail address
> that is hiding that you are a Mellanox employee?

For the same reason as I do. It is much easier to use outside servers
than Mellanox's IT infrastructure.

Right now, I'm speaking for myself, but for me, to properly answer with @mellanox.com,
I need to use very specific mail setup, while for any other addresses I can and use any
sane setup, including mobile application.

>
> Bart.

--eGyD7iWN192kf2IJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkOu0AACgkQ5GN7iDZy
WKfHTQ/+LJdIUqd9u7Oc07+rMCgDCGN2gGWvu+5ZRRW3uh+7Z2oQcvlxJEY6xfDw
zeAOvYqq0s6RT3jv2yqPnthfeq12efRmN691qZg0SlsDviOjgh3gzPZp/W2OlXOV
hN5LtWweKhnhz2fRiY51pLBn0xPhAA+iWuILY7lagNKCCuRTs2f/9R7JRxEZ2dz9
VLkdi9y4Laa0vLUym3SBJSJ0Q2ul/M1rfGts/GBxyyT2Cc/w7gQGQrGJ2i4gYUVr
9mophggzj3SxFvmNQSdY8Xja3VnfEvUCMXREZhUPHGUJJ3EyJ/9TdL+iSgEWAsTo
jUbeN5TEUg2V8GTC57m1XNPczKWb3YRItrU185g/rf92edIQbCdijKeYWmijzOVG
O8URlLd36uNefo9ubMMICN3KbLf7DM2kF3Dp3EkT0iwtX8lay31NUXjpcBCvgwEM
oFxJTj0bJt0i9EhAgO2Tiap4wE8zoMGVBRjGiwx6/zpDchooIXRQi+mntnFUqkgc
+eO4oU6vHNzTCRWNfgEbcR8DzXSx9eimTnsunul8LmNiWMuxR9mL/2pTisj3ioxj
f8lVzwa/yCKRPIlabL2AToMx90D0EyTfU2P3dmVSPMQkeIQdwEhfDuAm656ZQro3
Y8M/+35l0a/07TqwjDzeCcs8NsRcx7ec+rhjL+p/0mSnszV75Aw=
=0C+O
-----END PGP SIGNATURE-----

--eGyD7iWN192kf2IJ--
