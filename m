From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC VLAN 00/10]: VLAN netlink support try 2
Date: Tue, 05 Jun 2007 09:25:40 -0700
Message-ID: <46658E84.1090301@candelatech.com>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:56772 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760229AbXFEQZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 12:25:41 -0400
In-Reply-To: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> The last VLAN patchset was outdated, sorry about the mixup. These are the
> correct patches. The iproute patch I posted was correct, so no repost of
> that one.
>
>   
Is there any significant performance penalty in creating VLANs using 
these patches?

If you have a test station handy, could you let us know what 'time' 
shows for a script
creating 4000 VLANs with the old vconfig/ioctl method v/s this new method?

I'll try to look through the rest of the patches in detail later today.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


