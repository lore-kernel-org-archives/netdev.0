From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v3 00/16] Low-level Ethernet debugging features.
Date: Sat, 11 Feb 2012 08:20:24 -0800
Message-ID: <4F369548.6010106@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com> <4F361F2B.9030908@gmail.com> <20120211105118.GB14335@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56397 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab2BKQU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 11:20:29 -0500
In-Reply-To: <20120211105118.GB14335@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2012 02:51 AM, Francois Romieu wrote:
> Jeff Kirsher<tarbal@gmail.com>  :
> [...]
>> drivers.  But if the Realtek maintainer is fine with the changes, I will
>
> It seems ok.
>
> I'll test during the WE and check the status of the 8139cp (not the 8139too).
> It probably works like the 816x.

Yes, I think the 8139cp should be similar, but I don't have any hardware
that uses that driver...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
