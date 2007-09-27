From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Subject: TCP Spike
Date: Thu, 27 Sep 2007 11:58:01 +0800
Message-ID: <F444CAE5E62A714C9F45AA292785BED3223F7283@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw17.credit-suisse.com ([198.240.130.182]:36732 "EHLO
	nys17a-3002.corpny.csfb.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751657AbXI0D6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 23:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We have observed 40ms latency spikes in TCP connections in "burst" type of traffic. This affects regular TCP sockets. We observed this issue in kernels of 2.4.21 and kernel 2.6.5.  

Aparently, this seems to be fixed in 2.6.19.  

Can someone throw some light on this? 

Is this a congestion control/avoidance issue? What congestion control algorithm is used before 2.6.8?   

Thanks

Rajib



==============================================================================
Please access the attached hyperlink for an important electronic communications disclaimer: 

http://www.credit-suisse.com/legal/en/disclaimer_email_ib.html
==============================================================================

