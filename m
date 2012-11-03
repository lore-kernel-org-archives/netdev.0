From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH v2 9/9] net: batman-adv: use per_cpu_add
	helper
Date: Sat, 03 Nov 2012 23:39:44 +0100
Message-ID: <6126628.VHIlOyj2ru@sven-desktop.home.narfation.org>
References: <5093EE7E.6040400@gmail.com> <5905519.yWN2Ke3YlE@bentobox>
 <5094A485.4060409@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1797397.lfZIgvKNiC";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org,
 Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, lindner_marek-LWAfsSFWpa4@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5094A485.4060409-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--nextPart1797397.lfZIgvKNiC
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Saturday 03 November 2012 12:58:45 Shan Wei wrote:
> Sven Eckelmann said, at 2012/11/3 1:55:
> > On Saturday 03 November 2012 00:02:06 Shan Wei wrote:
> >> From: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
> >> 
> >> As Christoph Lameter said:
> >>> In addition, following usage of per_cpu_ptr can be replaced by
> >>> this_cpu_read.
> >>> 
> >>> cpu=get_cpu()
> >>> ....
> >>> *per_cpu_ptr(p,cpu)
> >>> ....
> >>> ....
> >>> put_cpu()
> >> 
> >> Right.
> >> 
> >> Signed-off-by: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
> >> ---
> > 
> > Is this really supposed to be the commit message?
> 
> Maybe it's ok when Linus said this. :-)
> 
> Christoph is the maintainer of per-cpu.
> So........

Hm? This wasn't my question, but ok...

Kind regards,
	Sven
--nextPart1797397.lfZIgvKNiC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQlZ0wAAoJEF2HCgfBJntGyDUQALAPrg6zTPAyMpKdS3PNXEsb
JSwhZtUHdEpgxg9DKqjt+1+d20Ts4yWiMuN50+MFirgiFr/I99gatwXBO59JzONx
QPipCTA1LiguBkrWKbjuNvehx3VugNrV63NK0vkQ/6ZYnYtA1lTNGpYln648/FY+
3+O8uq1RN3IvakTuQvxAmT5yH0ekCOud/GZZQxbxDBkTNEcQzHgpeo4kNUPv59B6
lrLSCy5xrbqf+faiwbVlTwERIhiT/T94aPoYPQMlAtbQWjEBagy43YEm51Pk8ypC
hdeB5KSyODj2BSfFNFxOZzVIU9nhDqdK89QPKMrrLz6YFfvFDg8dfJmpr0ZR2O/J
cBsfqM4lFfkM3sWO35J5YVMLZPPE5Ow12iJHIEgADytXUomR2HlqacbuxhPSJKTv
O/y3bol4zQsbLY2svZnKnu5Z8RY8yI9rqraP47a91jcNP20asdLOF3r1BvdHnG8V
iB9ssmnihV6eT3Fx/rDQVSa+yVNHHJFula2C63dzyYABz3l+DqZZ2+kytgVyqD5B
68qofLyzh/eh9N4vWaWgbLHQZl5eezDw9/IMQ4s+9qrKuiX99osnl5Lyi/o7A7fz
qDneMxs1mr619E7e8GNlyJRqAJAzyzV9nPLM5dVpF85NOz3sKctrMq/nvJbGxoAh
UaxRMFnt63+pdRQjLe7c
=pgnc
-----END PGP SIGNATURE-----

--nextPart1797397.lfZIgvKNiC--
