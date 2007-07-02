From: Jeff Garzik <jeff@garzik.org>
Subject: Re: RESEND [PATCH 1/3] NetXen: Fix issue of MSI not working correctly
Date: Mon, 02 Jul 2007 08:26:17 -0400
Message-ID: <4688EEE9.1030004@garzik.org>
References: <20070701185558.881537150@netxen.com> <20070701190014.878166067@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com,
	Milan Bag <mbag@netxen.com>, Wen Xiong <wenxiong@us.ibm.com>
To: dhananjay.phadke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50975 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbXGBM0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:26:21 -0400
In-Reply-To: <20070701190014.878166067@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dhananjay.phadke@gmail.com wrote:
> NetXen driver uses PCI function 0 to provide the functionality of MSI.
> The patch makes driver check the bus master bit for function 0 and
> enable it after the card initialization.
> 
> Signed-off-by: Dhananjay Phadke<dhananjay@netxen.com>
> Signed-off-by: Milan Bag <mbag@netxen.com>
> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>

applied patch #1 and #2 (dated July 1, 2:55PM)

applied patch #3 (dated July 2, 12:07 AM)


