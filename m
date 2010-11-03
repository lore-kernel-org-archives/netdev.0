From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [Patch] netxen: remove unused firmware exports
Date: Wed, 3 Nov 2010 04:35:01 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FCEAB435D@MNEXMB2.qlogic.org>
References: <20101103043021.5321.73681.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:39849 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab0KCJgm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 05:36:42 -0400
In-Reply-To: <20101103043021.5321.73681.sendpatchset@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Amerigo Wang [amwang@redhat.com]
> Sent: Wednesday, November 03, 2010 9:55 AM
> To: linux-kernel@vger.kernel.org
> Cc: Dhananjay Phadke; Amit Salecha; Narender Kumar; netdev@vger.kernel.org; David S. Miller; Amerigo Wang
> Subject: [Patch] netxen: remove unused firmware exports
>
> Quote from Amit Salecha:
> 
> "Actually I was not updated, NX_UNIFIED_ROMIMAGE_NAME (phanfw.bin) is already
> submitted and its present in linux-firmware.git.
>
> I will get back to you on NX_P2_MN_ROMIMAGE_NAME, NX_P3_CT_ROMIMAGE_NAME and
> NX_P3_MN_ROMIMAGE_NAME. Whether this will be submitted ?"
>
> We have to remove these, otherwise we will get wrong info from modinfo.
>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
> Cc: Narender Kumar narender.kumar@qlogic.com

Acked-by:  Amit Kumar Salecha <amit.salecha@qlogic.com>