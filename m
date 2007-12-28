From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6.25] CAN: Fix plain integer definitions in userspace
 header & new CAN version 20071227
Date: Fri, 28 Dec 2007 11:10:32 +0100
Message-ID: <4774CB98.30001@hartkopp.net>
References: <477407C1.1050405@hartkopp.net> <20071227.164900.233018217.davem@davemloft.net> <4774C14F.9010809@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, urs@isnogud.escape.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:42146 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbXL1KKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 05:10:35 -0500
In-Reply-To: <4774C14F.9010809@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> David Miller wrote:
>> The types are exactly the same size regardless of anything.
>>
>> There is no reason to make such a big fuss about this, changing the
>> CAN version etc.
>>

Btw. you are perfectly right with your remark. I'll revert the CAN 
version in the SocketCAN SVN back to 20071116 which is in net-2.6.25.

Sorry for the noise.

Oliver

