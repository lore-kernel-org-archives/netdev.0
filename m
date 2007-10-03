From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH RESEND] [11/11] pasemi_mac: enable iommu support
Date: Wed, 03 Oct 2007 14:19:14 -0400
Message-ID: <4703DD22.3090805@pobox.com>
References: <20071002212421.GA2282@lixom.net> <20071002212818.GL2282@lixom.net> <4703D5A5.1080204@pobox.com> <20071003180354.GB19319@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47104 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758852AbXJCSTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 14:19:16 -0400
In-Reply-To: <20071003180354.GB19319@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> pasemi_mac: enable iommu support
> 
> Enable IOMMU support for pasemi_mac, but avoid using it on non-partitioned
> systems for performance reasons.
> 
> The user can override this by selecting the PPC_PASEMI_IOMMU_DMA_FORCE
> configuration option.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied

