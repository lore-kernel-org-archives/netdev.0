From: David Miller <davem@davemloft.net>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Sun, 23 Oct 2011 23:24:16 -0400 (EDT)
Message-ID: <20111023.232416.1038111296509565828.davem@davemloft.net>
References: <20111023233558.GA23264@shutemov.name>
	<20111023.204943.1509703901636083438.davem@davemloft.net>
	<20111024013406.GA24158@shutemov.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	gregkh@suse.de, gladkov.alexey@gmail.com
To: kirill@shutemov.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708Ab1JXD1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 23:27:06 -0400
In-Reply-To: <20111024013406.GA24158@shutemov.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Mon, 24 Oct 2011 04:34:07 +0300

> On Sun, Oct 23, 2011 at 08:49:43PM -0400, David Miller wrote:
>> From: "Kirill A. Shutemov" <kirill@shutemov.name>
>> Date: Mon, 24 Oct 2011 02:35:58 +0300
>> 
>> > Is there something fundamental preventing us to have sysfs interface for
>> > network configuration?
>> 
>> Netlink already provides everything sysfs would potentially provide as
>> well as event tracking.
> 
> Not everything. You still need special utilities to view/change the
> configuration.

You can use netlink to perform any configuration change you want, or
to view any network configuration setting.
