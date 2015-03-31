From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 10/23] ptp: e1000e: convert to the 64 bit
 get/set time methods.
Date: Tue, 31 Mar 2015 19:26:19 -0400 (EDT)
Message-ID: <20150331.192619.1232312566406899847.davem@davemloft.net>
References: <cover.1427662906.git.richardcochran@gmail.com>
	<fe1c6929e8568acbc329d75beef97ed8977eeac1.1427662907.git.richardcochran@gmail.com>
	<20150331214815.GA9233@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	amirv@mellanox.com, ariel.elior@qlogic.com, arnd@linaro.org,
	baolin.wang@linaro.org, ben@decadent.org.uk,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	cmetcalf@ezchip.com, Frank.Li@freescale.com,
	peppe.cavallaro@st.com, jacob.e.keller@intel.com,
	jeffrey.t.kirsher@intel.com, john.stultz@linaro.org,
	b45643@freescale.com, matthew.vick@intel.com, mchan@broadcom.com,
	prashant@broadcom.com, rayagond@vayavyalabs.com,
	sshah@solarflare.com, linux-net-drivers@solarflare.com,
	sonic.zhang@analog.com, stefan.sorensen@spectralink.com,
	tglx@linutronix.de, thomas.lendacky@amd.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbbCaX0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 19:26:25 -0400
In-Reply-To: <20150331214815.GA9233@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 31 Mar 2015 23:48:15 +0200

> How are we supposed to print that field?  With a cast?

I resolved this (and the one in igb) in my merge commit, maybe you
should check it out.
