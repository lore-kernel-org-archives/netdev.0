From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Thu, 25 Aug 2016 07:57:01 -0400
Message-ID: <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="pd8q7gdL9bnnPaaLIgE4JNFcI7Qk2rPin"
Cc: xavier.huwei@huawei.com, oulijun@huawei.com,
        yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: David Miller <davem@davemloft.net>, salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160824.215341.1803699371957253329.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pd8q7gdL9bnnPaaLIgE4JNFcI7Qk2rPin
Content-Type: multipart/mixed; boundary="H2IW4T3f1CE4AE5jNKwQd5LECgs6i8Tns"
From: Doug Ledford <dledford@redhat.com>
To: David Miller <davem@davemloft.net>, salil.mehta@huawei.com
Cc: xavier.huwei@huawei.com, oulijun@huawei.com, yisen.zhuang@huawei.com,
 mehta.salil.lnk@gmail.com, linux-rdma@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com
Message-ID: <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
In-Reply-To: <20160824.215341.1803699371957253329.davem@davemloft.net>

--H2IW4T3f1CE4AE5jNKwQd5LECgs6i8Tns
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 8/25/2016 12:53 AM, David Miller wrote:
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Wed, 24 Aug 2016 04:44:48 +0800
>=20
>> This patch is meant to add support of ACPI to the Hisilicon RoCE drive=
r.
>> Following changes have been made in the driver(s):
>>
>> Patch 1/2: HNS Ethernet Driver: changes to support ACPI have been done=
 in
>>    the RoCE reset function part of the HNS ethernet driver. Earlier it=
 only
>>    supported DT/syscon.
>>
>> Patch 2/2. HNS RoCE driver: changes done in RoCE driver are meant to d=
etect
>>    the type and then either use DT specific or ACPI spcific functions.=
 Where
>>    ever possible, this patch tries to make use of "Unified Device Prop=
erty
>>    Interface" APIs to support both DT and ACPI through single interfac=
e.
>>
>> NOTE 1: ACPI changes done in both of the drivers depend upon the ACPI =
Table
>>      (DSDT and IORT tables) changes part of UEFI/BIOS. These changes a=
re NOT
>>      part of this patch-set.
>> NOTE 2: Reset function in Patch 1/2 depends upon the reset function ad=
ded in
>>      ACPI tables(basically DSDT table) part of the UEFI/BIOS. Again, t=
his
>>      change is NOT reflected in this patch-set.
>=20
> I can't apply this series to my tree because the hns infiniband driver
> doesn't exist in it.
>=20

No.  This probably needs to go through my tree.  Although with all of
the requirements, I'm a bit concerned about those being present elsewhere=
=2E

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--H2IW4T3f1CE4AE5jNKwQd5LECgs6i8Tns--

--pd8q7gdL9bnnPaaLIgE4JNFcI7Qk2rPin
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXvt0YAAoJELgmozMOVy/dU4YP/2x18n9M5wIGH1+/OtK80g+m
YUeikRrdM54A1xPo8HkufqGlq09OKmNNnBh6C3QhOtX2k4wsiltkzS/7iXRMRqpO
JFMqXgStv1sKbTL4XGRoNpRQcWWLeNMVgB9rsK9Fy2ptqcoy8j9WCIV/CKM058GB
Syp8CzzMJu5YimRHwL8bek11xRB2BPE1GgCUMDqyjBRiIM3NcCWTw9fpcfXndAIJ
Sx7ZYtyLRgpSidlavcmV3KDgpor6NeGNejRNJrStws50F5K55AJrYk/QjLE7wHxK
3hn/s2VUs4DyymdL8xeqhiRUsiYRI4eT/XhHQsCdLcwE8r1XBwyUKUzvZ7SqMvRD
YXTRannecTQBIfeqkaxxvuX/IBr03Vge9SfAgIxcZvOJtephMjinTaGuxCRGZSXg
uu1Ix/Egk9wpPYCYNUFbpLhPY7niBSNc8bWQY/vb8xkst2c9lQizia/fNSJxxiw6
D+zfKBAhtUOmYdKaEsB26lou3d7sL7PSu6nBAr4wYLMzjbAVJXDfJIxLisSlU7AC
zOVV8Tso4Rqe2evGkDSlhymv7+tStycJOqtWlf7SQbTQ+hasvdC4jxyY8iVZ1HWL
CDlBprDcwUB1myciUldU+0Y4L5Ctw8Kthzpq/Q7sBH0nsdBTvuzpoDJgQRTTtuva
+XJUdkqsivXVXZy8Jl0Z
=WZLw
-----END PGP SIGNATURE-----

--pd8q7gdL9bnnPaaLIgE4JNFcI7Qk2rPin--
