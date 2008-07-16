From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Wed, 16 Jul 2008 18:17:30 +0300
Message-ID: <487E110A.6010201@mellanox.co.il>
References: <487B6569.5000806@mellanox.co.il> <adabq0zdjy1.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:47829 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759588AbYGPPSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 11:18:32 -0400
In-Reply-To: <adabq0zdjy1.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
>  > +struct mlx4_en_cqe {
> 
> Same as WQE structs ... can we share the existing struct mlx4_cqe from
> <linux/mlx4/cq.h>?
> 
Will change the code to reuse the structs defined in mlx4_core

Thanks, Yevgeny
