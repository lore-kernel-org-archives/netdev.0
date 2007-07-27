From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Fri, 27 Jul 2007 09:00:27 -0400
Message-ID: <46A9EC6B.3030208@garzik.org>
References: <200707201741.45079.ossthema@de.ibm.com> <46A785C2.9090708@myri.com> <200707271418.49781.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Gallatin <gallatin@myri.com>,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57361 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755139AbXG0NAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 09:00:34 -0400
In-Reply-To: <200707271418.49781.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just to chime in...

In general, I like where this LRO effort is going, and I really 
appreciate you guys working on it.

	Jeff



