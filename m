From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Mon, 14 Aug 2006 00:44:00 +1000
Message-ID: <20060813144400.GJ479@krispykreme>
References: <44D99F38.8010306@de.ibm.com> <20060811215225.GH479@krispykreme> <44DE03B0.1060607@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <themann@de.ibm.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, roland@topspin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:27857 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751264AbWHMOpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 10:45:03 -0400
To: Thomas Klein <osstklei@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44DE03B0.1060607@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> I agree, stubbs were removed.

Thanks.

What is going to be done about the debug infrastructure in the ehea
driver? The entry and exit traces really need to go, and any other debug
you think is important to users needs to go into debugfs or something
similar.

I see a similar issue in the ehca driver that I am in the middle of
reviewing.

Anton
