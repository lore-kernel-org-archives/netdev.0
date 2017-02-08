From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v2 1/5] bpf: Add missing header to the library
Date: Wed, 8 Feb 2017 21:25:36 +0100
Message-ID: <27c01bf5-64b0-030a-f76f-2b5409956af5@digikod.net>
References: <20170206204027.29078-1-mic@digikod.net>
 <c83cb57a-c997-3785-b763-a63b4b7114d4@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="n9laf1NMGhApcWTdKQ7H4tw7uSXGAL355"
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c83cb57a-c997-3785-b763-a63b4b7114d4@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--n9laf1NMGhApcWTdKQ7H4tw7uSXGAL355
Content-Type: multipart/mixed; boundary="kATrJwGRAR2JvLFapuWummVAESESpsGR5";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: "Wangnan (F)" <wangnan0@huawei.com>, linux-kernel@vger.kernel.org
Cc: Alexei Starovoitov <ast@fb.com>,
 Arnaldo Carvalho de Melo <acme@redhat.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 "David S . Miller" <davem@davemloft.net>, Joe Stringer <joe@ovn.org>,
 netdev@vger.kernel.org
Message-ID: <27c01bf5-64b0-030a-f76f-2b5409956af5@digikod.net>
Subject: Re: [PATCH v2 1/5] bpf: Add missing header to the library
References: <20170206204027.29078-1-mic@digikod.net>
 <c83cb57a-c997-3785-b763-a63b4b7114d4@huawei.com>
In-Reply-To: <c83cb57a-c997-3785-b763-a63b4b7114d4@huawei.com>

--kATrJwGRAR2JvLFapuWummVAESESpsGR5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 08/02/2017 03:52, Wangnan (F) wrote:
> Please add me into the cc list of all of the 5 patches.

Sorry, get_maintainer.pl didn't get your name for all patches but I'll
CC you for the next series.

>=20
> Thank you.
>=20
> On 2017/2/7 4:40, Micka=C3=ABl Sala=C3=BCn wrote:
>> Include stddef.h to define size_t.
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Wang Nan <wangnan0@huawei.com>
>> ---
>>   tools/lib/bpf/bpf.h | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
>> index a2f9853dd882..df6e186da788 100644
>> --- a/tools/lib/bpf/bpf.h
>> +++ b/tools/lib/bpf/bpf.h
>> @@ -22,6 +22,7 @@
>>   #define __BPF_BPF_H
>>     #include <linux/bpf.h>
>> +#include <stddef.h>
>>     int bpf_create_map(enum bpf_map_type map_type, int key_size, int
>> value_size,
>>              int max_entries, __u32 map_flags);
>=20
>=20
>=20


--kATrJwGRAR2JvLFapuWummVAESESpsGR5--

--n9laf1NMGhApcWTdKQ7H4tw7uSXGAL355
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlibfsAACgkQIt7+33O9
apUnEAf/ZE5Nf3GLZPo5j135q1MS0n4GlJFC52u/mmwkRD5KUZk49Wsyl+XgBLQz
/SdtKSL6LpQ+yugNV4WBzohwkd15zfyPFpmRwzyRtH6ap2rnQ0Y10RiLHUacpGgj
sLzQ34hjkIYCXGbKQAxBxYcc1uJgE+uPmnZN3ceHshMZexcudmx4G4HrNyVLS2AL
CiwuZCo+6O2nCAH94hdK4s8dSVki2m5HKI2T8DFO+gtHh2oNrk2Znj6lcfPTXHOI
am2hV+vMSbgQfU/J9DLEupePuU48EEok9fKlya/kdRfhpTVVTBLJoTSBSEk71H44
61CQ38Wtw1EO680c1hEjfO7LYO7o1A==
=Yh3d
-----END PGP SIGNATURE-----

--n9laf1NMGhApcWTdKQ7H4tw7uSXGAL355--
