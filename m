From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: Convert to new vlan model.
Date: Fri, 24 Jun 2011 18:42:42 -0700
Message-ID: <03E840D17E263A48A5766AD576E0423A0129262C4D@exch-mbx-111.vmware.com>
References: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: VMware PV-Drivers <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:22448 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab1FYBmv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 21:42:51 -0400
In-Reply-To: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse. 

Very grateful for your fixes.

> This converts the vmxnet3 driver to use the new vlan model.  In 
> doing so it fixes missing tags in tcpdump and failure to do 
> checksum offload when tx vlan offload is disabled.
> 
> CC: Shreyas Bhatewara <sbhatewara@vmware.com>
> CC: VMware PV-Drivers <pv-drivers@vmware.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Scott J. Goldman <scottjg@vmware.com>

-sjg
