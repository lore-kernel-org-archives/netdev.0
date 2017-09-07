From: "Guedes, Andre" <andre.guedes@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 21:51:53 +0000
Message-ID: <1504821112.2117.8.camel@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
         <20170907053411.GA6580@sisyphus.home.austad.us>
         <20170907124018.deinzo3c4ice3q7n@localhost>
         <20170907152751.GA9064@sisyphus.home.austad.us>
         <20170907155315.5gqy5e4susl25wa2@localhost>
         <20170907161838.GB9064@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=sha-1;
        protocol="application/x-pkcs7-signature"; boundary="=-B4hlQQCcjjZspDxwQEiC"
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "Sanchez-Palencia, Jesus" <jesus.sanchez-palencia@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "henrik@austad.us" <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50712 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932552AbdIGVv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 17:51:58 -0400
In-Reply-To: <20170907161838.GB9064@sisyphus.home.austad.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-B4hlQQCcjjZspDxwQEiC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-09-07 at 18:18 +0200, Henrik Austad wrote:
> On Thu, Sep 07, 2017 at 05:53:15PM +0200, Richard Cochran wrote:
> > On Thu, Sep 07, 2017 at 05:27:51PM +0200, Henrik Austad wrote:
> > > On Thu, Sep 07, 2017 at 02:40:18PM +0200, Richard Cochran wrote:
> > > And if you want to this driver to act as a bridge, how do you accomod=
ate=C2=A0
> > > change in network requirements? (i.e. how does this work with switchd=
ev?)
> >=C2=A0
> > To my understanding, this Qdisc idea provides QoS for the host's
> > transmitted traffic, and nothing more.
>=20
> Ok, then we're on the same page.
>=20
> > > - Or am I overthinking this?
> >=C2=A0
> > Being able to configure the external ports of a switchdev is probably
> > a nice feature, but that is another story.=C2=A0 (But maybe I misunders=
tood
> > the authors' intent!)
>=20
> ok, chalk that one up for later perhaps

Just to clarify, we've been most focused on end-station use-cases. We've
considered some bridge use-cases as well just to verify that the proposed
design won't be an issue if someone else goes for it.

- Andre
--=-B4hlQQCcjjZspDxwQEiC
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
UizwODL0ejWFvIsCUeYSP2hojKPWo+Rd3xqVimkMF4BtboMY1QcGgHrUz+39T0ykiwIDAQABo4IC
LzCCAiswHQYDVR0OBBYEFGx9NuU31zGSN+jD/sIvs5oY7S+3MB8GA1UdIwQYMBaAFB5pKrTcKP5H
GE4hCz+8rBEv8Jj1MGUGA1UdHwReMFwwWqBYoFaGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9z
aXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNy
bDCBnwYIKwYBBQUHAQEEgZIwgY8waQYIKwYBBQUHMAKGXWh0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDRBLmNydDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuaW50ZWwuY29tLzALBgNVHQ8E
BAMCB4AwPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlngd69
OZXwQwIBZAIBCTAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3FQoE
HDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwSQYDVR0RBEIwQKAmBgorBgEEAYI3FAIDoBgM
FmFuZHJlLmd1ZWRlc0BpbnRlbC5jb22BFmFuZHJlLmd1ZWRlc0BpbnRlbC5jb20wDQYJKoZIhvcN
AQEFBQADggEBAE+EXag/N5PkW1uXsayWx3r4MzYFcznK3N1UG/6qR+UUB/PD4tbgU5M+IoP9gOp+
hzTOxM1PWxhyD24upEzuinkJ3BknENUeFZEaWnYQi306SMzJP3CzEiWogQ2/+JJXYb2vvQjeKEaq
mFdqshHJ7uFxdjmCYHlxmZte2oBC6DbaKeHcHyFxe0xxuaTwOQE3OoJNVcxpN2xK9rbnoe2a/oeg
LLn91PvxSNgjH0QC/TeY5kf5Pif4RAKi9ZsI6OwPhEpFhZbTJISCwmgdGcK/mVGyVtBaXciOboVJ
EwrCLsa+eAhbGn4F4MwTumo6oyzZa2SkenXS5M7chmcL0FvJ6F4xggIXMIICEwIBATCBkDB5MQsw
CQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQKExFJ
bnRlbCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBD
QSA0QQITMwAAi3Vjd570fy3HwgAAAACLdTAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqG
SIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTcwOTA3MjE1MTUyWjAjBgkqhkiG9w0BCQQxFgQUcJdC
+NL3RpR5QG6a87pctg4rFncwDQYJKoZIhvcNAQEBBQAEggEAawM2LdBdmH3ig6L69yio4L7n4JQf
Gq2d3ejU26I/DRf+z39bu7DAlPEJNQTi24npYxADb5mnYHbRv4HJIxcqu3bKh+3Pk3spprhp6Jz+
N8v1V+lbF0ELpxnm4VmQ+IXJH0woGwlDY5unikUulbKYOfKj2mkHpUaew7Tj86wqEHllKQ8cDygj
6fO/2uBnIqGrB2hx2+CMdPYy8ToAT3in0A4vlhiFpG6ZXJ+quhd6akrHkngFPaCEu/phglTSjs2o
ilnNZYNkpZaSNgSSSYvDTicr/75bqwdyD6jmA6gLDNRl/09vhK8hA8IsFF6xSyQ78CCHqPSYIY07
bWqSjIOu3gAAAAAAAA==


--=-B4hlQQCcjjZspDxwQEiC--
