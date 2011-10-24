From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Mon, 24 Oct 2011 00:59:00 -0400 (EDT)
Message-ID: <20111024.005900.1091819103500072631.davem@davemloft.net>
References: <20111024013406.GA24158@shutemov.name>
	<20111023.232416.1038111296509565828.davem@davemloft.net>
	<20111024042400.GA31344@shutemov.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	gregkh@suse.de, gladkov.alexey@gmail.com
To: kirill@shutemov.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab1JXFBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 01:01:49 -0400
In-Reply-To: <20111024042400.GA31344@shutemov.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Mon, 24 Oct 2011 07:24:00 +0300

> On Sun, Oct 23, 2011 at 11:24:16PM -0400, David Miller wrote:
>> From: "Kirill A. Shutemov" <kirill@shutemov.name>
>> Date: Mon, 24 Oct 2011 04:34:07 +0300
>> 
>> You can use netlink to perform any configuration change you want, or
>> to view any network configuration setting.
> 
> You need /sbin/ip or similar tool to do this, right?

I'm talking about udev using netlink natively.
