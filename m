From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH V2 for-next 0/8] Bug Fixes and Code Improvement in HNS
 driver
Date: Thu, 13 Oct 2016 07:57:00 -0400
Message-ID: <5c193c81-8907-09cb-a120-bff5b4782b00@redhat.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
 <20160930.013341.118711534087556597.davem@davemloft.net>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A74F326@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="mmi38dDkkiqpfxokG9MgI0nnkSuk6B2VN"
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        oulijun <oulijun@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754543AbcJML7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 07:59:16 -0400
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A74F326@lhreml503-mbx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mmi38dDkkiqpfxokG9MgI0nnkSuk6B2VN
Content-Type: multipart/mixed; boundary="WO20sxl4RMJTc8XbFcF4HGXG8m5w832EU";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Salil Mehta <salil.mehta@huawei.com>, David Miller <davem@davemloft.net>
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
 "Huwei (Xavier)" <xavier.huwei@huawei.com>, oulijun <oulijun@huawei.com>,
 "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Linuxarm <linuxarm@huawei.com>
Message-ID: <5c193c81-8907-09cb-a120-bff5b4782b00@redhat.com>
Subject: Re: [PATCH V2 for-next 0/8] Bug Fixes and Code Improvement in HNS
 driver
References: <20160929170916.631972-1-salil.mehta@huawei.com>
 <20160930.013341.118711534087556597.davem@davemloft.net>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A74F326@lhreml503-mbx>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A74F326@lhreml503-mbx>

--WO20sxl4RMJTc8XbFcF4HGXG8m5w832EU
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/13/2016 7:26 AM, Salil Mehta wrote:
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Friday, September 30, 2016 6:34 AM
>> To: Salil Mehta
>> Cc: dledford@redhat.com; Zhuangyuzeng (Yisen); Huwei (Xavier); oulijun=
;
>> mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
>> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
>> Subject: Re: [PATCH V2 for-next 0/8] Bug Fixes and Code Improvement in=

>> HNS driver
>>
>> From: Salil Mehta <salil.mehta@huawei.com>
>> Date: Thu, 29 Sep 2016 18:09:08 +0100
>>
>>> This patch-set introduces fix to some Bugs, potential problems
>>> and code improvements identified during internal review and
>>> testing of Hisilicon Network Subsystem driver.
>>>
>>> Submit Change
>>> V1->V2: This addresses the feedbacks provided by David Miller
>>>         and Doug Ledford
>>
>> So Doug my understanding is if this makes it through review
> Hi Dave,
> A gentle reminder regarding this. I was wondering if you think these
> have been reviewed enough and by any chance these patches can be includ=
ed
> in current 4.9 merge window. This will save us a lot of effort.
>=20
> As I understand Doug is waiting for your review approval on this
> patch-set.

I am, and I was just getting ready to ask again today myself.

> Thanks in anticipation
> Best regards
> Salil =20
>> this is going to be merged into your tree, you prepare a
>> branch for me, and then I pull from that?
>>
>> Thanks in advance.


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--WO20sxl4RMJTc8XbFcF4HGXG8m5w832EU--

--mmi38dDkkiqpfxokG9MgI0nnkSuk6B2VN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/3aSAAoJELgmozMOVy/dlZkQAKXw+Qvg9I56C8I9O0Oq698n
g+bucQfTq5YXXGvmGiTBLKorPc8GdRajFyv3wbRQiOcAOGWFXSda3X0ePEFuJ2Qp
UrafChHX8QfUOwh7zSTZY6mabcGmCNaRn/2Qm9mTH5iJ+HGnhuNIIog31LSGYTAn
bPiilboAyq1bx9uBWT0SPY+DNd6cLC9ao8Jhgwi2IC8Jd0Aqc7MvEi75BSg1ClV0
MkOKEfWPTfmQNOyUUHS4lXG48lIk+SxqtE9iIQ/OKYImAFkTPcqS80nraczCV/69
wK4lZ4p8mqxJN/hxfFOtn1BcQbpUg5ZEmqxM1vdvMl5m69z5RVNfboNWkAaSa/4M
P0ITYyAMp4iE0SXsEJwtI08g94wOLrgUjrH5kxqZyw45KX8aGaoFv7TlrBOq5icg
2lPmbrOWF0CfgxlQuM+A9B1zkJqWG2Zi5LvrLzAVyimWasrzE4Yj3TqwLQbW7cQW
Nd4UzNG6jTciFsNMzZ4GGWBrYGtUrrm/QyqEZB1f4mLSiFJbGxsE3lwLX6+sa6vP
2ty2dm0E3oaNJzzCBFQdjKMa19o2RSjBu40hocfn8hJOXmu63F6dPUaS9tsAJr14
zYQ+ICgK2QT1g6r5mlJ56pBTCrd34rBJTQ4wpcpYp8MwLXDIIze4eMSP8vbMsh7W
arcCBJ3fWG8AlgDC3KHu
=UuZD
-----END PGP SIGNATURE-----

--mmi38dDkkiqpfxokG9MgI0nnkSuk6B2VN--
