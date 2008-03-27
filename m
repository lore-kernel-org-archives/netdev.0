From: "Denis V. Lunev" <den@openvz.org>
Subject: SCTP control socket question
Date: Thu, 27 Mar 2008 15:03:53 +0300
Message-ID: <1206619433.32459.9.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:1077 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756393AbYC0MED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 08:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Vlad!

I have read SCTP sources and found that SCTP control socket
(sctp_ctl_socket) remains hashed unlike similar staff in UDP/TCP etc.

Am I wrong, that it should not be hashed or not?

Regards,
	Den

