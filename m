From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 4/4] NFC: nxp-nci: Allow module removal during download
Date: Fri, 30 Jan 2015 01:08:33 +0100
Message-ID: <20150130000833.GC20998@ribalta.ger.corp.intel.com>
References: <1421940460-14049-1-git-send-email-clement.perrochaud@effinnov.com>
 <1421940460-14049-5-git-send-email-clement.perrochaud@effinnov.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfc@lists.01.org,
	=?iso-8859-1?Q?Cl=E9ment?= Perrochaud
	<clement.perrochaud@nxp.com>, sunil.jogi@nxp.com,
	jerome.pele@nxp.com, Charles.Gorand-Effinnov@nxp.com,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, grant.likely@linaro.org, lefrique@marvell.com,
	christophe.ricard@gmail.com, cuissard@marvell.com,
	bzhao@marvell.com, hirent@marvell.com, akarwar@marvell.com,
	linux-wireless@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clement.perrochaud@effinnov.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421940460-14049-5-git-send-email-clement.perrochaud@effinnov.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Clement,

On Thu, Jan 22, 2015 at 04:27:40PM +0100, clement.perrochaud@effinnov.c=
om wrote:
> From: Cl=E9ment Perrochaud <clement.perrochaud@nxp.com>
>=20
> Signed-off-by: Cl=E9ment Perrochaud <clement.perrochaud@nxp.com>
> Signed-off-by: Cl=E9ment Perrochaud <clement.perrochaud@effinnov.com>
> ---
>  drivers/nfc/nxp-nci/core.c     | 7 +++----
>  drivers/nfc/nxp-nci/firmware.c | 9 ++++++---
>  2 files changed, 9 insertions(+), 7 deletions(-)
Please squash that one into the first patch.

Cheers,
Samuel.
