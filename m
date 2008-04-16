From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 3/3] igb: save and restore pcie/msi state to support EEH
 recovery
Date: Wed, 16 Apr 2008 11:08:02 -0700
Message-ID: <48064082.8010202@intel.com>
References: <20080415175745.12506.67349.stgit@localhost.localdomain>	<20080415175757.12506.3922.stgit@localhost.localdomain> <20080416091345.e479cd30.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, wendyx@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16907 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbYDPSJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 14:09:15 -0400
In-Reply-To: <20080416091345.e479cd30.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> On Tue, 15 Apr 2008, Auke Kok wrote:
> 
>> To enable EEH support for pci-express network adapters, pcie/msi state
>> needs to be saved and restored for that adapter.
>>
>> [after similar patches for ixgbe and e1000e from Wendy Xiong]
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: Wendy Xiong <wendyx@us.ibm.com>
>> ---
>>
>>  0 files changed, 0 insertions(+), 0 deletions(-)
> 
> Was there supposed to be a patch here?

I messed up.. new patch coming in a sec.

Auke
