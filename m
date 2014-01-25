From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v3 0/2] bonding: Fix some issues for fail_over_mac
Date: Sat, 25 Jan 2014 12:56:51 +0800
Message-ID: <52E34413.4030003@huawei.com>
References: <52E1EBB0.6040505@huawei.com> <20140124.180427.1942816445484474722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>,
	<andy@greyhouse.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2658 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbaAYE5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 23:57:19 -0500
In-Reply-To: <20140124.180427.1942816445484474722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/25 10:04, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Fri, 24 Jan 2014 12:27:28 +0800
> 
>> So set the fail_over_mac to none if the mode is not active-backup and
>> slight optimization for bond_set_mac_address().
> 
> This is no longer how your series fixes the problem, please fix this
> text and resubmit.
> 
> 
OK, sorry for that.
