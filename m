From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] netem: fix build error on 32bit arches
Date: Thu, 01 Dec 2011 10:46:12 +0100
Message-ID: <dbe5bc9736645f7d4ba06cab15b03512@localhost>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
 <1322691627-20551-2-git-send-email-hagen@jauu.net>
 <1322710225.2577.1.camel@edumazet-laptop>
 <cfd2e2c26063da002d8afe76991ff0c1@localhost>
 <1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:59720 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751172Ab1LAJqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:46:13 -0500
In-Reply-To: <1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 01 Dec 2011 10:32:14 +0100, Eric Dumazet wrote:



> ERROR: "__udivdi3" [net/sched/sch_netem.ko] undefined!

> 

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>



Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>
