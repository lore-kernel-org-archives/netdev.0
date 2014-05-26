From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 1/1] net: tso: Export symbols for modular build
Date: Mon, 26 May 2014 08:15:21 -0300
Message-ID: <20140526111521.GA9273@arch.cereza>
References: <1401096166-5409-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Sachin Kamat <sachin.kamat@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:36789 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751750AbaEZLQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 07:16:03 -0400
Content-Disposition: inline
In-Reply-To: <1401096166-5409-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 May 02:52 PM, Sachin Kamat wrote:
> Export the symbols to fix the below errors when built as modules:
> ERROR: "tso_build_data" [drivers/net/ethernet/marvell/mvneta.ko] unde=
fined!
> ERROR: "tso_build_hdr" [drivers/net/ethernet/marvell/mvneta.ko] undef=
ined!
> ERROR: "tso_start" [drivers/net/ethernet/marvell/mvneta.ko] undefined=
!
> ERROR: "tso_count_descs" [drivers/net/ethernet/marvell/mvneta.ko] und=
efined!
> ERROR: "tso_build_data" [drivers/net/ethernet/marvell/mv643xx_eth.ko]=
 undefined!
> ERROR: "tso_build_hdr" [drivers/net/ethernet/marvell/mv643xx_eth.ko] =
undefined!
> ERROR: "tso_start" [drivers/net/ethernet/marvell/mv643xx_eth.ko] unde=
fined!
> ERROR: "tso_count_descs" [drivers/net/ethernet/marvell/mv643xx_eth.ko=
] undefined!
>=20
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>

Acked-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Thanks for the fix,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
