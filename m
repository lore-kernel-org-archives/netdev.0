From: Grant Grundler <grundler@parisc-linux.org>
Subject: RFC : PATCH for dmfe phy reset needs testing
Date: Sun, 23 Mar 2008 20:31:02 -0600
Message-ID: <20080324023102.GA474@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:55277 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125AbYCXCbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 22:31:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm got a patch to fix this dmfe driver bug report:
    http://bugzilla.kernel.org/show_bug.cgi?id=2776

But the reporter hasn't responded in ~6 months.
Can someone with dmfe card test the patch for me?

Patch can be pulled from:
    http://iou.parisc-linux.org/~grundler/diff/diff-2.6.23-rc3-dmfe_phy-01

Once it's tested, I'd like to submit and close the bug.

thanks,
gran
