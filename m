From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC 0/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 04 Aug 2007 04:47:41 -0400
Message-ID: <46B43D2D.2090800@garzik.org>
References: <1186200229.18322.97.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, anilgv@broadcom.com,
	talm@broadcom.com, lusinsky@broadcom.com, uri@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971AbXHDIrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2007 04:47:46 -0400
In-Reply-To: <1186200229.18322.97.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [BNX2]: Add iSCSI support to BNX2 devices.
> 
> Modify bnx2 and add a cnic driver to support some offload functions
> needed by iSCSI.
> 
> Add a new open-iscsi driver to support iSCSI offload on bnx2 devices.
> 
> Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> --
> 
> The complete patch is in:
> 
> ftp://Net_sys_anon@ftp1.broadcom.com/0001-BNX2-Add-iSCSI-support-to-BNX2-devices.patch
> 
> I broke this into 2 patches and omitted the firmware blob in the next 2
> emails for review.

patch #2/2 did not make it (to me personally nor to 
http://marc.info/?l=linux-netdev)

	Jeff



