From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [Intel-wired-lan] [PATCH] ixgbe: Limit lowest interrupt rate
 for adaptive interrupt moderation to 12K
Date: Tue, 1 Sep 2015 22:44:15 -0700 (PDT)
Message-ID: <alpine.NEB.2.11.1509012243190.1164@chris.i8u.org>
References: <20150730221927.984.91700.stgit@ahduyck-vm-fedora22> <55E655A3.9010304@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-87-25-Oregon.hfc.comcastbusiness.net ([75.148.87.25]:49952
	"EHLO chris.i8u.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbbIBFxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 01:53:03 -0400
In-Reply-To: <55E655A3.9010304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2015, Alexander Duyck wrote:

> On 07/30/2015 03:19 PM, Alexander Duyck wrote:
>> This patch updates the lowest limit for adaptive interrupt interrupt
>> moderation to roughly 12K interrupts per second.
...
> Has there been any update on this patch?  I submitted it just over a month 
> ago now and it hasn't received any feedback.  I was hoping this could be 
> submitted before the merge window closes for net-next.
>
> Thanks.

I'm nobody, but it makes sense to me.

-- 
Hisashi T Fujinaka - htodd@twofifty.com (also todd.fujinaka@intel.com)
BSEE + BSChem + BAEnglish + MSCS + $2.50 = coffee
