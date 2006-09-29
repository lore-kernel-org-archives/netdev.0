From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Fri, 29 Sep 2006 17:28:39 -0400
Message-ID: <451D9007.6010905@garzik.org>
References: <1159564053.3741.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35006 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161450AbWI2V2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 17:28:45 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1159564053.3741.19.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> AMD believes this incompatibility is unique to the 5706, and
> prefers to locally disable MSI rather than globally disabling it
> using pci_msi_quirk.

Why is it unique to the 5706?  Is this just a guess on AMD and 
Broadcom's part?

	Jeff


