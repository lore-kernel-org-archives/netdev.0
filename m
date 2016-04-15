From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
 (Hyper-V)
Date: Fri, 15 Apr 2016 00:19:09 +0000
Message-ID: <5927A4E8-E3FF-4C79-9B5A-6656183CDCA8@intel.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-2-git-send-email-kys@microsoft.com>
 <5F69AC74-16B9-4EAD-8B4B-21D2EB6B3653@intel.com>
 <SN2PR03MB1919133D2E9B5DDBC2AED643A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
 <DA0F5562-FC38-4037-B018-42116DD142E8@intel.com>
 <SN2PR03MB19196E84DF934294DE7BB739A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6478340883192057482=="
Cc: "olaf@aepfle.de" <olaf@aepfle.de>, netdev <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "jackm@mellanox.com" <jackm@mellanox.com>,
 "yevgenyp@mellanox.com" <yevgenyp@mellanox.com>, "Ronciak,
 John" <john.ronciak@intel.com>,
 intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
 "eli@mellanox.com" <eli@mellanox.com>, "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <SN2PR03MB19196E84DF934294DE7BB739A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

--===============6478340883192057482==
Content-Language: en-US
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F8574A88-29DC-4457-9B36-5A668D42BEF3";
	protocol="application/pgp-signature"; micalg=pgp-sha256

--Apple-Mail=_F8574A88-29DC-4457-9B36-5A668D42BEF3
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

KY Srinivasan <kys@microsoft.com> wrote:

>
>
>> -----Original Message-----
>> From: Rustad, Mark D [mailto:mark.d.rustad@intel.com]
>> Sent: Thursday, April 14, 2016 5:07 PM
>> To: KY Srinivasan <kys@microsoft.com>
>> Cc: David Miller <davem@davemloft.net>; netdev
>> <netdev@vger.kernel.org>; linux-kernel@vger.kernel.org;
>> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
>> jasowang@redhat.com; eli@mellanox.com; jackm@mellanox.com;
>> yevgenyp@mellanox.com; Ronciak, John <john.ronciak@intel.com>; intel-
>> wired-lan@linuxonhyperv.com
>> Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
>> (Hyper-V)
>>
>> KY Srinivasan <kys@microsoft.com> wrote:
>>
>>>> -----Original Message-----
>>>> From: Rustad, Mark D [mailto:mark.d.rustad@intel.com]
>>>> Sent: Thursday, April 14, 2016 4:01 PM
>>>> To: KY Srinivasan <kys@microsoft.com>
>>>> Cc: David Miller <davem@davemloft.net>; netdev
>>>> <netdev@vger.kernel.org>; linux-kernel@vger.kernel.org;
>>>> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
>>>> jasowang@redhat.com; eli@mellanox.com; jackm@mellanox.com;
>>>> yevgenyp@mellanox.com; Ronciak, John <john.ronciak@intel.com>;
>> intel-
>>>> wired-lan@linuxonhyperv.com
>>>> Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
>>>> (Hyper-V)
>>>>
>>>> Some comments below:
>>>
>>> Mark,
>>>
>>> Thank you for the comments. I will address them and repost the patches.
>>>
>>> Regards,
>>>
>>> K. Y
>>
>> Please look closely at Alex's comments. I think they are much more
>> important.
>
> I am looking at Alex's comments as I am writing this.
>
> K. Y
>> --
>> Mark Rustad, Networking Division, Intel Corporation

Can you please stop putting that crazy intel-wired-lan@linuxonhyperv.com in  
your messages? It doesn't exist.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_F8574A88-29DC-4457-9B36-5A668D42BEF3
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJXEDN9AAoJEDwO/+eO4+5u5W0QAKOPU+8g0DlKPiJx/hjO6GTR
XISa/NF8O3iRcpcVUuN+jJON+xiCjlHTmkQuzvx++v9UzvaWK0JQnF7XBdzPHOzD
ZFm81h8jg4F87TdsZgyrYMcuV7BSn6YvHTubvHM7ef3I1fQGAFi8wlbw2unm8NU8
SDOzjY/FH2MA1eQHZzI8eSMmSoB49LQShMTARvEkUr/G/lHQ62eA+UecwNgSMeTY
EYg8SckaGGpkYshAboQGuBrp2Yyx+w0m47WBfeSZGRtRD5qBJnoHFNJ2DgJcY1b5
uu3aNwfJfvfKA+tyijbP2xKraAOlM09nh0SDAYxzAPLWBQXVq6oQr/v3lgRvtHQy
bRIuVCvBU0udg0Pxji9ruZ8ltoR/Ds+DZCn2cOT18YubNPnsPULDlEDDhFbxhPUe
WzjbAdk+ec1XbwddzK+1nclNca1nAEwE8m+tMDK6hZfM8JXd6Y7R7qyRxrkWKuV4
E3Zb58obdqm4aaJc05YJ2ApjweUGLTNuv1QKL4YqCCSCWSJi5f91j907Lp083KR8
4kW2dSEarDADmBvgeHqQVISXPdFcLHGK4aCg9Xwh9dpOO2EdsrVx/qomitTf+AgU
L5oGP5p3rM8pvjA9kb5azTS6Z/u2PiHGhLG2K0ODMHYh8M+mAQICL6PFMe1TMhLS
n7GjobbuwK2m4j6Mo2eD
=+JlE
-----END PGP SIGNATURE-----

--Apple-Mail=_F8574A88-29DC-4457-9B36-5A668D42BEF3--

--===============6478340883192057482==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============6478340883192057482==--
