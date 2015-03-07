From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [trivial PATCH net-next] ethernet: codespell comment spelling
 fixes
Date: Sat, 07 Mar 2015 18:12:03 +0000
Message-ID: <1425751923.4027.17.camel@decadent.org.uk>
References: <1425703752.12017.66.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+x6kxjVokSRhI3xB/Cmt"
Cc: netdev <netdev@vger.kernel.org>,
	Masanari Iida <standby24x7@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53588 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750815AbbCGSMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 13:12:21 -0500
In-Reply-To: <1425703752.12017.66.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+x6kxjVokSRhI3xB/Cmt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-06 at 20:49 -0800, Joe Perches wrote:
[...]
> --- a/drivers/net/ethernet/sfc/vfdi.h
> +++ b/drivers/net/ethernet/sfc/vfdi.h
> @@ -98,7 +98,7 @@ struct vfdi_endpoint {
>   * @VFDI_OP_INIT_TXQ: Initialize SRAM entries and initialize a TXQ.
>   * @VFDI_OP_FINI_ALL_QUEUES: Flush all queues, finalize all queues, then
>   *	finalize the SRAM entries.
> - * @VFDI_OP_INSERT_FILTER: Insert a MAC filter targetting the given RXQ.
> + * @VFDI_OP_INSERT_FILTER: Insert a MAC filter targeting the given RXQ.
>   * @VFDI_OP_REMOVE_ALL_FILTERS: Remove all filters.
>   * @VFDI_OP_SET_STATUS_PAGE: Set the DMA page(s) used for status updates
>   *	from PF and write the initial status.
> @@ -148,7 +148,7 @@ enum vfdi_op {
>   * @u.init_txq.flags: Checksum offload flags.
>   * @u.init_txq.addr: Array of length %u.init_txq.buf_count containing DM=
A
>   *	address of each page backing the transmit queue.
> - * @u.mac_filter.rxq: Insert MAC filter at VF local address/VLAN targett=
ing
> + * @u.mac_filter.rxq: Insert MAC filter at VF local address/VLAN targeti=
ng
>   *	all traffic at this receive queue.
>   * @u.mac_filter.flags: MAC filter flags.
>   * @u.set_status_page.dma_addr: Base address for the &struct vfdi_status=
.
[...]

I was going to claim this was the British spelling, but my dictionary
says you're right. :-)

Ben.

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-+x6kxjVokSRhI3xB/Cmt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVPs/fee/yOyVhhEJAQoJ5BAAmTERpEoQXnbypln7+lc8IuohFjokxO+G
9ji7dcc+LjeHNTyWhEyIOzdFQkW8lVEpLKyyzITqJvNojAdLgesBy3X8SdLIW1ly
mfzgAuVoZjA2chNf9YuZOY8ZPdgns94/I4jSKNgTSiylClJ8CuAKLEbylKNX9E3J
8QARuZZXVeTE6GpK19nUzO2kTo8Q1ywzUS7Efo3OfWfC4eEw2KDxnXLtNdh52el1
LNNVtpD//Uo5fewIR3D9AvqMpLRMfGNVyuCDQseRfKik92EOxD2DSieTGPqG6Wbp
whMI5Be6jkuWGf0t3VVXK3DQSzJpFd8YitB4A1fepUVxWmL1oVUvzK9+zxrHF5FN
fZH4x1nbclJR3HYKK82QRzFTgMUr7n8N4w0ls4mztpvfi5Vv3UtUCrxxuv4ZwK+O
zIqTONUOXMpYVaGEtkwLVSIpGVCvryVk9kZsZavWbr+/Y3a8J7fd0pLCaBsITWJf
7AkHnp2BM3HEvUxvJsnaWZDN4DkN5UhfxDdG1sBjLPMFOXJup+zBiHMTsDsVX+1R
cNhdAYVbmuWw8N4gwDskbsrjbkVqJYDhRkd+pmUDG3QUf03jlsSEFJiPEqUPMSrH
dSY5qdxkOiwfl9Kg48vbXxXFCpz6bM4SHDbcxq9XbDhuO2RIh2jcyTYgi+iFCy8R
5eOy8liS4iw=
=Hi2o
-----END PGP SIGNATURE-----

--=-+x6kxjVokSRhI3xB/Cmt--
