From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH 8/8] ibm_newemac: Skip EMACs that are marked unused by the firmware
Date: Wed, 21 Nov 2007 08:13:51 +0100
Message-ID: <200711210813.51525.sr@denx.de>
References: <20071121060737.6AA72DDE0C@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:55200 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105AbXKUHNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 02:13:30 -0500
In-Reply-To: <20071121060737.6AA72DDE0C@ozlabs.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 21 November 2007, Benjamin Herrenschmidt wrote:
> From: Hugh Blemings <hugh@blemings.org>
>
> Depending on how the 44x processors are wired, some EMAC cells
> might not be useable (and not connected to a PHY). However, some
> device-trees may choose to still expose them (since their registers
> are present in the MMIO space) but with an "unused" property in them.
>
> Signed-off-by: Hugh Blemings <hugh@blemings.org>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Acked-by: Stefan Roese <sr@denx.de>

Best regards,
Stefan
