From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 0/2] NetXen: Fix NetXen driver on system-P
Date: Fri, 4 May 2007 09:07:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705040905470.21891@dut46>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>, Rob Mapes <rob@netxen.com>,
	netxenproj@linsyssoft.com
To: netdev mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:32845 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1031035AbXEDQHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 12:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi All,

Thanks for your feedback  Christoph. I have dropped that conditional
checking of pdev->class in this patchset.

These patches are wrt netdev#upstream.

Regards,
Mithlesh Thukral
