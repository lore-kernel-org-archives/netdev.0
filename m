From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25.3 1/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Fri, 27 Jun 2008 01:35:12 -0400
Message-ID: <48647C10.1090604@garzik.org>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE603B863@SHEXMB-01.global.atheros.com> <20080626214510.01373505@osprey.hogchain.net> <72981EBCFD196144B7C6999B9FC34A9A3EE603BB7C@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jie Yang <Jie.Yang@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38924 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbYF0FfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:35:17 -0400
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A3EE603BB7C@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jie Yang wrote:
> From: Jay Cliburn [acliburn@bellsouth.net]
> Date: Friday, June 27, 2008 10:45 AM
> 
>> Patches 1 and 2 reviewed tonight.  I intend to review the
>> other 3 in coming days.
> 
> Thanks for your help.
> I will update source code on these comments.
> 
>> On Thu, 26 Jun 2008 13:37:23 +0800
>> Jie Yang <Jie.Yang@Atheros.com> wrote:
>>
>>> From: Jie Yang <jie.yang@atheros.com>
>>>
>>> Full patch for the Atheros L1E Gigabit Ethernet driver.
>>> Supportring AR8121, AR8113 and AR8114
>> Please generate the patch against current mainline (or at
>> least current -rc); it fails to apply cleanly as is.
>>
> 
> how about use the git
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev.git

You'll want to use

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

Regards,

	Jeff


