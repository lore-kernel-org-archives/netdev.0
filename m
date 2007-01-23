From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 4/5] s2io: Removed enabling of some of the unused
 interrupts.
Date: Tue, 23 Jan 2007 00:47:22 -0500
Message-ID: <45B5A16A.4000703@garzik.org>
References: <Pine.GSO.4.10.10701190243190.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	sriram.rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45367 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933006AbXAWFrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:47:24 -0500
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10701190243190.22012-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> Removed unused code in en_dis_able_nic_intrs(), TX_DMA_INTR, RX_DMA_INTR,
> TX_XGXS_INTR, MC_INTR
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

ACK


