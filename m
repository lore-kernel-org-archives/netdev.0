From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PULL] virtio: virtio 1.0 support, misc patches
Date: Fri, 12 Dec 2014 10:24:26 +1100
Message-ID: <20141212102426.187891e9@canb.auug.org.au>
References: <20141211120248.GA8838@redhat.com>
	<20141212080705.50988d51@canb.auug.org.au>
	<20141211220157.GA22618@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1578740532523253536=="
Cc: sergei.shtylyov@cogentembedded.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	pbonzini@redhat.com, ben@decadent.org.uk,
	David Miller <davem@davemloft.net>, thuth@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141211220157.GA22618@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============1578740532523253536==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/eFK=miiM5Yby3J+6.8OqxSZ"; protocol="application/pgp-signature"

--Sig_/eFK=miiM5Yby3J+6.8OqxSZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On Fri, 12 Dec 2014 00:01:57 +0200 "Michael S. Tsirkin" <mst@redhat.com> wr=
ote:
>
> It was on linux next for a while, then I wanted to tweak the commit log
> for some messages a bit.
> So since I rewrote the history anyway, I went ahead and rebased it
> on v3.18, after this rebase it's been in linux-next for several days.

Maybe you think you pushed it into a linux-next included branch (or
maybe you think I am fetching a branch that I am not), but when I look
at those commits in my tree (as I fetch Linus' tree into mine) none of
them precede any of the next-* tags ...

I am not doubting that these patches have been published and reviewed
and tested, all I am saying is that they have not been in linux-next
as those commits.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/eFK=miiM5Yby3J+6.8OqxSZ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUiieuAAoJEMDTa8Ir7ZwVQhoP/1V96HlYTLRMzvYvV9d0aDUg
vvs8fmlbrbozr4VTTg72fBWwDIvVpEzi+y+JLlXRAm7d0T8/wngpw6dGSObghIvT
xzCLobJVl7qyfg5iy4wbkJQeTpf57NHXWvEgvH7PiofQwxUaEhlp+optDa66abk4
uE8kBLqHYQukP+zw29LYCABs8J/tAocJV88YMDcB4OeCqNv+LHxCQ940HVqMUvSl
XGH5k2BN+I+Ccg/WihleNXoa3yfoEtv9W2TiF/06jq4+Ef+zA6nc+ZFgcgFZh3gb
Mbb3DrhJdBNWXx3956KCWPBdxRPKlOs8j5Lu2kA6Hbpi7y5BnyGY7195NEcfpibW
Y6C7ZVMntIGWvx93DB6V6+Hwu1pVpXF1Ksk7lexE4tDPa8LKgjIylpJO4Czd+4pd
3WzfvsdjkHW4+NhJTFonomwJsEe7LkfLz545gylWDZv5KrNl6en2BFypGW4uxln2
rnT/6/S0ZFGu3F1P5T9G5Rwlh0PsT3f4s4YCNE2NIq/Q6aTQmvRou1YJp1A6hN4O
6OZw0OC/2tNrFmoO6vJ8L5F34udl2T1rN2rMFQHXW06wOyzi6AutZAR0JkM6SrZf
3qIX5qPjH2pK/b6ipZt4xwgZcoVUUKnGAEElMLXjSOiaAnW3MqhMZLufhlrqT/Gu
hy+fdx9lx9QJLVrYwgsM
=nKIE
-----END PGP SIGNATURE-----

--Sig_/eFK=miiM5Yby3J+6.8OqxSZ--

--===============1578740532523253536==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============1578740532523253536==--
