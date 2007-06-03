From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/5] NetXen: Multicast filter for NetXen driver
Date: Sun, 03 Jun 2007 11:49:37 -0400
Message-ID: <4662E311.50005@garzik.org>
References: <200706011114.l51BEZTx004682@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbXFCPtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 11:49:40 -0400
In-Reply-To: <200706011114.l51BEZTx004682@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Add multicast filter code
> This patch will add manage the multicast filter from driver.
> It will add capability to write multicast addresses to hardware.
> 
> Signed-by: Mithlesh Thukral <mithlesh@netxen.com>

as has been repeatedly noted, there are endianness bugs.  First I noted 
them, and apparently was ignored.  Then Michael Beusch noted them as well.

Will continue ignoring your buggy patch here.


