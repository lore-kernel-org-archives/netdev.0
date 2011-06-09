From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [Pv-drivers] [PATCH 1/9] vmxnet3: convert to 64 bit stats
 interface
Date: Wed, 8 Jun 2011 22:17:45 -0700
Message-ID: <F78BCF638F95D74A99D036114107EDB5028DE8C542@EXCH-MBX-3.vmware.com>
References: <20110609005356.160260858@vyatta.com>,<20110609005417.324633042@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:45286 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751238Ab1FIFTE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 01:19:04 -0400
In-Reply-To: <20110609005417.324633042@vyatta.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Convert vmxnet3 driver to 64 bit statistics interface.
> This driver was already counting packet per queue in a 64 bit value so not
> a huge change. Eliminate unused old net_device_stats structure.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks for taking care of this.

Signed-off-by: Scott J. Goldman <scottjg@vmware.com>
