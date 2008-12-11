From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Default offload settings in Ethernet drivers
Date: Thu, 11 Dec 2008 11:10:51 -0800
Message-ID: <494165BB.6030103@hp.com>
References: <49415EDB.3030006@computer.org> <20081211105459.3e615be8@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:41129 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756143AbYLKTLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 14:11:03 -0500
In-Reply-To: <20081211105459.3e615be8@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Go get a kill-a-watt meter and real hardware and measure.
> I don't think there will be any difference. Linux (mainline) doesn't
> do TOE. It does do segmentation offload, and any driver that can
> do segmentation offload enables it by default.

Further, it would seem reasonable to expect if a NIC has a feature the 
driver does not enable by default, the implication is that feature is 
not yet ready for regular use.

rick jones
