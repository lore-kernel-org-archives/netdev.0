From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V2 0/20] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Fri, 19 Oct 2012 04:37:18 -0400
Message-ID: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22997 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757972Ab2JSI4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 04:56:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, September 20, 2012 3:47 PM
> To: Sony Chacko
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH v1 0/19] qlcnic: patches for new adapter - Qlogic 
> 83XX CNA
> 
> I tired reviewing this driver just for coding style issues after just 
> looking at two or three of them.
> 
> I haven't even begun to think about the actual technical semantics and 
> correctness of these patches.  I doubt anyone else in the community 
> had either, and that won't even begin to happen until the coding style 
> issues are rectified.

Previous version of the patch set had lot style issues.
We have fixed the style issues without blindly relying on scripts. 

The following patch set will restructure existing Qlogic 82XX adapter driver
to create a common driver for 82XX and the new CNA - Qlogic 83XX.

Patches 1 to 13 - restructures existing 82XX adapter driver.
Patches 13 to 20 - 83XX adapter features.

Please apply the updated 20 patch series to net-next.

Thanks,
Sony
