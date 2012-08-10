From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 1/2] powerpc/85xx: add the Fman device tree template include
 files
Date: Fri, 10 Aug 2012 17:34:05 -0500
Message-ID: <50258C5D.5070108@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	<ddaney.cavm@gmail.com>, <linuxppc-dev@ozlabs.org>,
	<netdev@vger.kernel.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:18073
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620Ab2HJWeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 18:34:10 -0400
In-Reply-To: <1344637896-14267-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2012 05:31 PM, Timur Tabi wrote:
> Introduce the template include files for the Freecale Frame Manager (Fman).
> An SOC can have up to two Fman devices, and each Fman can have up to
> five 1G Ethernet MACs and one 10G Ethernet MAC.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0-10g-0.dtsi |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-0.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-1.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-2.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-3.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0-1g-4.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-0.dtsi       |  140 +++++++++++++++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1-10g-0.dtsi |   54 ++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-0.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-1.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-2.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-3.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1-1g-4.dtsi  |   63 +++++++++
>  arch/powerpc/boot/dts/fsl/qoriq-fman-1.dtsi       |  140 +++++++++++++++++++++
>  14 files changed, 1027 insertions(+), 0 deletions(-)

Where's the binding document for all this?  Why isn't devicetree-discuss
on CC?

-Scott
