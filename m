From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [Ubuntu PATCH] Broadcom wireless patch, PCIE/Mactel support
Date: Thu, 15 Jun 2006 22:39:42 -0700
Message-ID: <4492441E.1020907@oracle.com>
References: <44909A3F.4090905@oracle.com> <1150386115.2987.7.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de,
	akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58062 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1750749AbWFPEjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 00:39:23 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1150386115.2987.7.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> On Wed, 2006-06-14 at 16:22 -0700, Randy Dunlap wrote:
>> From: Matthew Garrett <mjg59@srcf.ucam.org>
>>
>> Broadcom wireless patch, PCIE/Mactel support
>>
>> http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=1373a8487e911b5ee204f4422ddea00929c8a4cc
>>
>> This patch adds support for PCIE cores to the bcm43xx driver. This is
>> needed for wireless to work on the Intel imacs. I've submitted it to
>> bcm43xx upstream.
> 
> 
> who's signing off on these patches??

Well, this particular one isn't going anywhere AFAIK, so it doesn't matter here.
For most of them, Ben Collins or someone else at Ubuntu has signed-off on them
(although not so on this one).

Let's continue the general discussion on the "reviewing" thread.

~Randy


