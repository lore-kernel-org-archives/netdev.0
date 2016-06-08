From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v9 00/22] Add HiSilicon RoCE driver
Date: Wed, 8 Jun 2016 07:55:11 -0400
Message-ID: <7860e33e-42a0-b98e-116d-45fd32d8acdd@redhat.com>
References: <1465368297-82118-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="h17xiHcsuxFEjPQEHrd9qkhqbt6BkUtlD"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465368297-82118-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--h17xiHcsuxFEjPQEHrd9qkhqbt6BkUtlD
Content-Type: multipart/mixed; boundary="t1kWgjFwJHFK8Ac69wRQIu0HdaxIB0pcB"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
 tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
 yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Message-ID: <7860e33e-42a0-b98e-116d-45fd32d8acdd-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v9 00/22] Add HiSilicon RoCE driver
References: <1465368297-82118-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
In-Reply-To: <1465368297-82118-1-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

--t1kWgjFwJHFK8Ac69wRQIu0HdaxIB0pcB
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 6/8/2016 2:44 AM, Lijun Ou wrote:
> The HiSilicon Network Substem is a long term evolution IP which is
> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
> Sybsystem) also has a hardware support of performing RDMA with
> RoCEE.
> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
> will support mulitple versions of SOCs in future. This version of drive=
r
> is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
> specifications).

Please don't resend unless you think the patch has gotten lost.  This is
a large patchset and takes a considerable deal of time to process.

That said, I pulled the v9 patchset into my repo in a branch called hns
yesterday and am doing final review before I accept it into my for-next
area.


--t1kWgjFwJHFK8Ac69wRQIu0HdaxIB0pcB--

--h17xiHcsuxFEjPQEHrd9qkhqbt6BkUtlD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXWAefAAoJELgmozMOVy/d/ogQAKt3rA+nrGDz8bjg3cUKr4oI
gYYapv/5WfC5STRW995DJESF1zJgD3UrdHfpxx+UxN1xevTHrlvfUruZGTHR/a2Y
gweHT6arYW5n6mgQLFw4/G14n+EFVjo9RHVhMU+zBNL36wxKKdXotb85rqUtFDih
0Ni2CQzVVuCL+8Y/5rqjCB9ZM+OI2uASrEH3p5wopdCPHq/0viUWnT8VsbwIu1Oe
rfFsCPTMfTZez71Y6bLXpF/k5JL7M/dvz6ZrD2v4s2uARWFV7ZtJ48fR4Aq2AchJ
IzmQX6hrjzQwePvXcE4ySwVscX7sf8bkL882O501bTqSoLVKVMeKTiyl6KLi86AX
FMow6QZXE014D6f6iYuleIphn0dkl4ZL1xj0cB7NdDaMgv/7pZ0u2E/YWbQazBD+
EIrNWfMSK7Xk+jRCnBYvHGszhSf5MN2KNMhPzOKB4+Zjyyl9x8RDhwIMlm6+BkOn
agXWyOf8MfFLV+C9r80KybXW3/LjCStm1Jm1jormGl0VzMs0EtFNBqG0HsIUJZTH
nqcVfFuMkGbWQbNQVWLEz/UkhhCbHYTMnJ+4ZzE5whY9CfQgy+hmfxGUcfaChabk
DAJ7LRM5oZjxxV9sNSfsmPAgUd5kdf4yAU3U0Yi1mrvfm8LuJnTxdNFHRXlziMgJ
qLR1ZW5aZ494Acnv1j7/
=vZmG
-----END PGP SIGNATURE-----

--h17xiHcsuxFEjPQEHrd9qkhqbt6BkUtlD--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
