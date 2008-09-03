From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH RFC 00/10 v2] mlx4_en: Mellanox ConnectX 10G NIC driver
Date: Wed, 03 Sep 2008 10:19:15 -0400
Message-ID: <48BE9CE3.4080208@pobox.com>
References: <487B655D.7030502@mellanox.co.il> <adad4lfezcv.fsf@cisco.com> <48AC154A.1020108@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54425 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbYICOT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:19:26 -0400
In-Reply-To: <48AC154A.1020108@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
> Hello Jeff,
> 
> This is the second round of 10 patches implements the Mellanox Technologies
> ConnectX 10G Nic driver - mlx4_en.
> 
> The ConnectX can operate as an InfiniBand adapter, as an Ethernet NIC, or as
> a Fibre Channel (FC) HBA.
> Hence, the mlx4_en module is part of the ConnectX drivers, which also includes
> a low level bus-driver - mlx4_core - and an Infiniband driver - mlx4_ib - that are
> already in the kernel and maintained by Roland Dreier.
> 
> mlx4_en implements a standard Ethernet netdevice and handles all the Ethernet-related
> logic of ConnectX.
> 
> The new series of patches include fixes that were made as according to feedbacks from
> the mailing list, and also some bug fixes.
> 
> This series of patches are based on patches that were already sent to mlx4_core module.
> We are now resubmitting those patches. There were no changes done to those patches
> other than adjusting to the latest kernel git.

Can you point me to, or email me privately, a single patch that adds the 
driver?

New driver additions need to occur in a single changeset.


