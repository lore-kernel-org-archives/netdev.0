From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: Performance issue : GRE tunneling
Date: Fri, 18 Jan 2008 13:48:12 +0000
Message-ID: <1200664092.22132.3.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: matthew.hattersley@vaioni.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:8061 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756468AbYARNtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 08:49:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
When i send the traffic outside of GRE tunnel, The speed is in 3-4Mbps.
When i use the tunnel for traffic, the speed get reduced huge. It is
around 100-300Kbps. What are the factors affects the performance when we
use tunneling [ ex:GRE tunneling ]?

Thanks
Jeba
