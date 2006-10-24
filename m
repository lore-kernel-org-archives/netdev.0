From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Mon, 23 Oct 2006 22:04:20 -0700
Message-ID: <453D9ED4.4030401@oracle.com>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:19389 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1752054AbWJXFDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 01:03:32 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061024050014.GC12506@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Mon, Oct 23, 2006 at 09:54:48PM -0700, Randy Dunlap wrote:
>> Similarly, sysfs is desirable in some circumstances, but
>> not for blocks of binary data.
> 
> sysfs specifically has APIs for binary data...

Ack that, sorry about that.

-- 
~Randy
