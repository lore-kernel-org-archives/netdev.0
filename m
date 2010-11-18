From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Thu, 18 Nov 2010 15:52:25 -0800
Message-ID: <1290124345.1817.53.camel@Joe-Laptop>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	 <1288316896.1836.41.camel@Joe-Laptop> <4CCB3BF1.7070000@windriver.com>
	 <1288390127.28828.225.camel@Joe-Laptop>
	 <1288396919.15283.23.camel@jtkirshe-MOBL1> <4CD323AF.20609@windriver.com>
	 <AANLkTim2yH7eAqqYQW+JVC5GtFR5mX4uZnMa02+yubFk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1554 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143Ab0KRXw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 18:52:27 -0500
In-Reply-To: <AANLkTim2yH7eAqqYQW+JVC5GtFR5mX4uZnMa02+yubFk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-11-04 at 19:28 -0700, Jeff Kirsher wrote:
> Joe and I are working to organize the drivers into
> /drivers/net/<technology> directories and to cleanup the Kconfig to
> reflect the organization.  Ethernet drivers will be in
> /drivers/net/ethernet, and so on.
[]
> We are hoping not to drag this out and plan on getting this into
> 2.6.38 (net-next) within the couple of weeks.

What is an appropriate time frame for doing these
reorganization file/directory moves for net-next?

David, do you have a preference?

