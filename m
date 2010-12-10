From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 03/27] Documentation/networking/igb.txt: update
 documentation
Date: Fri, 10 Dec 2010 12:21:49 -0800 (PST)
Message-ID: <20101210.122149.232731880.davem@davemloft.net>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291974667-30254-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<1291996224.11673.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, davem@davemleft.org,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754622Ab0LJUVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:21:22 -0500
In-Reply-To: <1291996224.11673.2.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 10 Dec 2010 15:50:24 +0000

> On Fri, 2010-12-10 at 01:50 -0800, Jeff Kirsher wrote:
>> Update Intel Wired LAN igb documentation.
>> 
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  Documentation/networking/igb.txt |   22 +++++++++++++++++++---
>>  1 files changed, 19 insertions(+), 3 deletions(-)
>> 
>> diff --git a/Documentation/networking/igb.txt b/Documentation/networking/igb.txt
>> index ab2d718..393bdb7 100644
>> --- a/Documentation/networking/igb.txt
>> +++ b/Documentation/networking/igb.txt
>> @@ -36,6 +36,7 @@ Default Value: 0
>>  This parameter adds support for SR-IOV.  It causes the driver to spawn up to
>>  max_vfs worth of virtual function.
>>  
>> +
>>  Additional Configurations
>>  =========================
>>  
>> @@ -60,7 +61,8 @@ Additional Configurations
>>    Ethtool
>>    -------
>>    The driver utilizes the ethtool interface for driver configuration and
>> -  diagnostics, as well as displaying statistical information.
>> +  diagnostics, as well as displaying statistical information. The latest
>> +  version of Ethtool can be found at:
>>  
>>    http://sourceforge.net/projects/gkernel.
> 
> Please update this to:
> http://ftp.kernel.org/pub/software/network/ethtool/

Indeed.

Intel folks, please address all of Ben's feedback and respin this
pull request, thanks.
