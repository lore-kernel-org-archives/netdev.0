From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: too many iterations (6) in nv_nic_irq
Date: Mon, 15 May 2006 22:11:42 -0400
Message-ID: <446934DE.2030905@pobox.com>
References: <445B22CA.4050405@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14040 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751049AbWEPCLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 22:11:45 -0400
To: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
In-Reply-To: <445B22CA.4050405@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carl-Daniel Hailfinger wrote:
> Hi Jeff,
> 
> IIRC you had "too many iterations (6) in nv_nic_irq" appear regularly
> in your dmesg with kernel 2.6.16. Did this disappear in more recent
> kernels? If not, can you try the disable_msi and disable_msix module
> parameters if they help in your case?

Yes, it disappeared in recent kernels.

	Jeff



