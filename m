From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the powerpc tree
Date: Fri, 9 Mar 2012 13:36:46 +1100
Message-ID: <20120309133646.fb8cc30d8c2fd0ef7784d72c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__9_Mar_2012_13_36_46_+1100_o.kx23tJ_UeCCL5P"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	<linuxppc-dev@lists.ozlabs.org>, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__9_Mar_2012_13_36_46_+1100_o.kx23tJ_UeCCL5P
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/ibm/iseries_veth.c between commit e92a665949f6
("net: powerpc: remove the legacy iSeries ethernet driver") from the
powerpc tree and commit 41de8d4cff21 ("drivers/net: Remove alloc_etherdev
error messages") from the net-next tree.

I just removed the file.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__9_Mar_2012_13_36_46_+1100_o.kx23tJ_UeCCL5P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPWWy+AAoJEECxmPOUX5FEdH4P/ifnYy1RxHVPjCgoKvc/4uzo
IbDU9QiuiCs3XZKqhxuMUP5+OQONJEL9xYDbu8ymmdGqML0iiASlZXhtUUbeVNBK
2DFcu7a+gWz9yDjZrLiRrJ7EENQXSMYQe5dBXWJ6ZdmLeUL8ILfbznkS3APV+U2q
LFGZ42Zb6Lpv3Bjs9wHnfmzHh1HtqXiLgPn0JYtaYG0Qs6IKVEtT3oQj3pKV8QyB
Wir9UjoiFTI6dEdSqDad4uPhfeuQznLIpzfOZD3+ZQztXsFq7/HpRYj3LMYjjvOF
jxd/TVyjVenSg12EwmcjW+75L+WDgPKjIi443pvelkCDHrThbrhpLXeTIW50o+dG
T8HVzjPLEKIDlj417wxYGyUSwXXxft2+yG6pepAolw3blLd1DLpGZjJVRvsv9ylM
0LRBIOQHn7EPo1vn+dNMQjKMWvbTIVtzShiGa2pfg8sZzNV9qWqrSItyCwBJV1GK
udMikVHd0H144elXgkARzPmK+nbhvbEIWos6NDeD6+8oFBLeVjix7U3JB5YZNVUa
vD55XiFAalVXlGPLoTMxPbBz1GEQ6A3o4Ndb6m1vq+dIGotvXlsrtKBOh9bF9lsl
WvCFTYOHj6hUVeoxold72Kg9J/y2r8Oo4eG0ItOyzSfZsx8HIUSuddkgoO/qEf9f
1u5oqD8hVemCFG7ZMpsK
=GHW+
-----END PGP SIGNATURE-----

--Signature=_Fri__9_Mar_2012_13_36_46_+1100_o.kx23tJ_UeCCL5P--
