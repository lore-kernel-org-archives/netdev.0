From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/3] ethtool: fix typo on setting speed 10000
Date: Mon, 28 Jan 2008 10:55:23 -0800
Message-ID: <479E251B.1000002@intel.com>
References: <20080107173602.8429.56354.stgit@localhost.localdomain> <4789434C.70801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22645 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757060AbYA1S4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 13:56:13 -0500
In-Reply-To: <4789434C.70801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>
>> fix the typo in speed 10000 setting.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  ethtool.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> patches 1 and 2 failed to apply.  applied #3

can you refresh the tree on http://git.kernel.org/?p=network/ethtool/ethtool.git ?

I did indeed send the first two patches out earlier but they did not show up on
git.kernel.org, hence I posted them again.

Thanks,

Auke
