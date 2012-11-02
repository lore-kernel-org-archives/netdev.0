From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V5 0/22] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Thu,  1 Nov 2012 21:06:32 -0400
Message-ID: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49093 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1759556Ab2KBB0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 21:26:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, November 01, 2012 9:04 AM
> To: Sony Chacko
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH v4 0/21] qlcnic: patches for new adapter - Qlogic 83XX
> CNA
> 
> 
> Patch #17 did not make it to the list, you have to make it smaller so that it fits.

Re-submitting the patch set after after splitting patch #17.

The following patch set will restructure existing Qlogic 82XX adapter
driver to create a common driver for 82XX and the new CNA - Qlogic 83XX.

Patches 1 to 11 - restructures existing 82XX adapter driver.
Patches 12 to 22 - 83XX adapter features.

Please apply the updated 22 patch series to net-next.

Thanks,
Sony
