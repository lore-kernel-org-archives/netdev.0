From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V3 0/21] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Tue, 23 Oct 2012 18:30:51 -0400
Message-ID: <1351031472-731-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:64429 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933543Ab2JWWuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 18:50:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, October 19, 2012 10:50 AM
> To: Sony Chacko
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH V2 12/20] qlcnic: 83xx base driver
>
> Patch is way too large and therefore didn't make it to the mailing list.
> So I'm tossing this entire series, please correct this and repost.

Re-submitting the patch series after splitting large patch.

Previous version of the patch set had lot style issues.
We have fixed the style issues without blindly relying on scripts.

The following patch set will restructure existing Qlogic 82XX adapter
driver to create a common driver for 82XX and the new CNA - Qlogic 83XX.

Patches 1 to 11 - restructures existing 82XX adapter driver.
Patches 12 to 21 - 83XX adapter features.

Please apply the updated 21 patch series to net-next.

Thanks,
Sony
