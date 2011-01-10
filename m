From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull-request] Intel Wired LAN Driver Updates
Date: Sun, 09 Jan 2011 23:45:38 -0800 (PST)
Message-ID: <20110109.234538.220065048.davem@davemloft.net>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1294360629.2622.28.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51339
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965Ab1AJHpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 02:45:07 -0500
In-Reply-To: <1294360629.2622.28.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 06 Jan 2011 16:37:09 -0800

> On Thu, 2011-01-06 at 16:29 -0800, Kirsher, Jeffrey T wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> 
>> The following series contains ixgbe/e1000e cleanups and fixes.  The
>> addition of CE4100 support in e1000, and ixgb VLAN conversion to the
>> new model.
>> 
>> The following changes since commit dbbe68bb12b34f3e450da7a73c20e6fa1f85d63a:
>> 
>>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
>> 
>> are available in the git repository at:
>> 
>>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master
 ...
> I apologize, I fat fingered Andy Gospodarek's email address.  I have
> corrected it in this response.

Since Jesse Gross found problems with patch #8 (the ixgb conversion to
the new VLAN model) I hand applied every patch except for #8 to my
tree while we wait for Emil's respin of that.
