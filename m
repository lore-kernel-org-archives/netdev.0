From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V6 0/22] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Mon,  5 Nov 2012 17:11:54 -0500
Message-ID: <1352153535-5006-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11664 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933266Ab2KEWbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2012 17:31:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, November 02, 2012 6:28 PM
> To: Sony Chacko
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH V5 04/22] qlcnic: modify PCI and register access routines
> 
> This removes the only user of qlcnic_check_vf() but leaves the definition
> around, dangling, and creating a build warning:
> 
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:454:1: warning:
> .qlcnic_check_vf. defined but not used [-Wunused-function]
> 
> 
> Thanks.

I apologize for the above mistake.
We have fixed the above warning and have verified the rest of the patches.
Please apply the updated 22 patch series to net-next.

Thanks,
Sony
