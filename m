From: Mohammad Alsaleh <msal@tormail.org>
Subject: ping -f is broken in iputils 20121011
Date: Tue, 30 Oct 2012 23:52:53 +0300
Message-ID: <1TTImq-000C5f-Bs@internal.tormail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing.tormail.org ([82.221.96.22]:58769 "EHLO
	outgoing.tormail.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab2J3Vbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 17:31:41 -0400
Received: from localhost ([127.0.0.1] helo=internal.tormail.org)
	by outgoing.tormail.org with esmtp (Exim 4.72)
	(envelope-from <msal@tormail.org>)
	id 1TTIoN-0005Ye-3H
	for netdev@vger.kernel.org; Tue, 30 Oct 2012 23:53:24 +0300
Received: from msal by internal.tormail.org with local (Exim 4.63)
	(envelope-from <msal@tormail.org>)
	id 1TTImq-000C5f-Bs
	for netdev@vger.kernel.org; Tue, 30 Oct 2012 20:51:50 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As explained in this bug report(1). ping -f seems to be broken in
iputils 20121011.

(1) https://bugs.archlinux.org/task/32306
