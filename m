From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Lots of tcp_recvmsg warnings in kerneloops list
Date: Fri, 13 Nov 2009 09:10:13 -0800
Message-ID: <20091113091013.2bef993e@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38467 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754294AbZKMRK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 12:10:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone looked into this? Is there a fix? Should it be sent to stable?

http://kerneloops.org/searchweek.php?search=tcp_recvmsg
