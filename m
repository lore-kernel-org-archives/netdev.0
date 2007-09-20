From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Add device IDs of blade version of the 82571 quad
 port
Date: Thu, 20 Sep 2007 16:33:54 -0700
Message-ID: <46F30362.8070301@intel.com>
References: <20070830182357.14185.69495.stgit@localhost.localdomain> <46F2E913.3080204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55838 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbXITXd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 19:33:57 -0400
In-Reply-To: <46F2E913.3080204@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Auke Kok wrote:
>> This blade-specific board form factor is identical to the 82571EB
>> board.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000_ethtool.c |    1 +
>>  drivers/net/e1000/e1000_hw.c      |    1 +
>>  drivers/net/e1000/e1000_hw.h      |    1 +
>>  drivers/net/e1000/e1000_main.c    |    2 ++
>>  4 files changed, 5 insertions(+), 0 deletions(-)
> 
> I just found this buried in a dusty corner of my inbox.  is this still
> needed?

yes absolutely, this is a rather good selling part afaik and it's nothing but a
new board with the same silicon (2x 82571 Fiber dual port behind a pci-e bridge).

Auke
