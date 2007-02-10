From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] phy layer: add kernel-doc + DocBook
Date: Sat, 10 Feb 2007 13:59:05 -0800
Message-ID: <45CE4029.3070505@oracle.com>
References: <20070207213026.3ae3c732.randy.dunlap@oracle.com> <45CCE8FC.7000304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, afleming@FREESCALE.COM,
	akpm <akpm@osdl.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:10731 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbXBJWDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 17:03:32 -0500
In-Reply-To: <45CCE8FC.7000304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Randy Dunlap wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> Convert function documentation in drivers/net/phy/ to kernel-doc
>> and add it to DocBook.
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> ---
>>  Documentation/DocBook/kernel-api.tmpl |    6 +
>>  drivers/net/phy/mdio_bus.c            |   19 ++-
>>  drivers/net/phy/phy.c                 |  192 
>> ++++++++++++++++++++++++----------
>>  drivers/net/phy/phy_device.c          |  114 +++++++++++++-------
>>  4 files changed, 234 insertions(+), 97 deletions(-)
> 
> ACK but patch does not support to linux-2.6.git

It does for me.  Do you mean that it doesn't apply to #netdev #upstream
or something like that?

-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
