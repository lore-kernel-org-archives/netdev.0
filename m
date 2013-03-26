From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Is there a preferred way to get the VXLAN port number?
Date: Tue, 26 Mar 2013 15:02:45 -0700
Message-ID: <51521B05.6060401@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>, pshelar@nicira.com,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51290 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab3CZWCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 18:02:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was wondering if someone would happen to know if there is already a
preferred way to get the VXLAN port number for things such as
configuring a device to recognize a VXLAN frame on receive for parsing
purposes?

I just wanted to check to make sure I hadn't missed something before
submitting a patch that would export a simple function for supplying the
vxlan_port value.

Thanks,

Alex
