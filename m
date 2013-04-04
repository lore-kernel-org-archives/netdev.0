From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH RFC 0/2] Add IPv6 tokenized interface identifier support
Date: Thu,  4 Apr 2013 16:37:36 +0200
Message-ID: <1365086258-4512-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761594Ab3DDOhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 10:37:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC patchset adds IPv6 tokenized interface identifier
support for the net-next kernel as well as for iproute2 in
order to configure a networking device for IPv6 Token IIDs.

For a more detailled description, have a look at the two
patches directly.

-- 
1.7.11.7
