From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH V3 0/7] Bundle fixes for Xen netfront / netback
Date: Tue, 9 Apr 2013 12:07:28 +0100
Message-ID: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<konrad.wilk@oracle.com>, <annie.li@oracle.com>,
	<wdauchy@gmail.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60032 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935782Ab3DILWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1-3 have been applied, repost them for completeness.

4 is incremental patch on top of 2 to fix log message and comment.

5 now accounts for vlan header.

6 is rewritten, please see commit log for details.

7 is slightly adjusted, but the logic remains the same as last version.
