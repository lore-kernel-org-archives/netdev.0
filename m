From: Eric Anholt <eric@anholt.net>
Subject: Re: [PATCH v3 1/2] net: dsa: b53: Add compatible strings for the
 Cygnus-family BCM11360.
Date: Mon, 01 May 2017 08:15:17 -0700
Message-ID: <87k260k3qy.fsf@eliezer.anholt.net>
References: <20170428222204.7103-1-eric@anholt.net>
 <20170430.224852.172293736555378453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1539902936145001713=="
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 sbranden@broadcom.com, vivien.didelot@savoirfairelinux.com,
 jonmason@broadcom.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devicetree@vger.kernel.org, robh+dt@kernel.org,
 bcm-kernel-feedback-list@broadcom.com, rjui@broadcom.com,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170430.224852.172293736555378453.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============1539902936145001713==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

David Miller <davem@davemloft.net> writes:

> From: Eric Anholt <eric@anholt.net>
> Date: Fri, 28 Apr 2017 15:22:03 -0700
>
>> Cygnus is a small family of SoCs, of which we currently have
>> devicetree for BCM11360 and BCM58300.  The 11360's B53 is mostly the
>> same as 58xx, just requiring a tiny bit of setup that was previously
>> missing.
>>=20
>> v2: Reorder the entry in the docs (suggestion by Scott Branden), add
>>     missing '"'
>>=20
>> Signed-off-by: Eric Anholt <eric@anholt.net>
>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>> Acked-by: Rob Herring <robh@kernel.org>
>
> The second patch with the DTS file update doesn't apply cleanly
> at all to net-next.
>
> So I'm dropping this series.

DTS updates go through arm-soc branches through Florian.  The first
patch is the one I would like you to apply.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE/JuuFDWp9/ZkuCBXtdYpNtH8nugFAlkHUQUACgkQtdYpNtH8
nui1WxAAhJ9AxuuGK8tGVrKEXZBruAo6l6kdmLOVMS7C5NNQSpCfuaKWxFwTpPYk
+MaOWWoK5J4xCGo+t469EfxnG8alclk8Jf8L8pSLJH/zpP/WNGwzBPYyPAmOjgCL
oP0TvPhxFnUue29L2lotlCsys57e5vnALmPQd5ou6eoleuejJC0k5u9BL+RpM+Py
mkaKTJhmR24IrMcTWPkgrnTD+Xy7ycFXkYRvgnkLqCu38jkgdlP95MPwfj3puPg1
LN645zFxKQey2+JHIG1+vwI9K6Wkrk7l58nvqMQVQ31hYFqz5979jj8P0CWQ1e4/
44S13zQhqsiNEr+iIWv5wBnZn6e1ppkMmgO2LFYcnyDrUn9I1RJtIx6Pb6+9eyI6
AaA4Ubb+PVJq4SqcMnjT7he3WcY1yjSSHPtHCySzEQrM0kDcfaU9uq5I+cZdPxJF
ae2hvghYnYvqmuReNJCyrRt+WFfPKKKhYAyiS3FxzZ7qMEHIX/QEAFai/6UCemj8
pNF5wfDl/t10dugsZ59ZPKgtpj787W2FdAzSQd3FC2mFqefEYG1Brn4tgCawi8e0
hM1HVfWViwmbSVSDNBvAwREHgulwMsLgOV5r9WYvKjT1nTlcd4/ArHLZ+c1Ta/qa
OaCQryUJKCBq8Yxx7858ihjiJroH10EBomM8AKBBSTbV0P9bNXU=
=5ERj
-----END PGP SIGNATURE-----
--=-=-=--


--===============1539902936145001713==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============1539902936145001713==--
