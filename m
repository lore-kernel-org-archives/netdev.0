From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next] qlge: use ethtool set_phys_id
Date: Mon, 11 Apr 2011 13:22:45 -0700 (PDT)
Message-ID: <20110411.132245.70184177.davem@davemloft.net>
References: <20110406164750.11cfeef3@nehalam>
	<20110411180246.GA8562@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Linux-Driver@qlogic.com,
	netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753756Ab1DKUXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:23:21 -0400
In-Reply-To: <20110411180246.GA8562@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 11 Apr 2011 11:02:46 -0700

> On Wed, Apr 06, 2011 at 04:47:50PM -0700, Stephen Hemminger wrote:
>> This is a stab at replacing old ethtool phys_id with set_phys_id
>> on the Qlogic 10Gb driver. Compile tested only.
>> 
>> Not sure if set_led_cfg will flash continuously, or needs
>> to be replaced by ETHTOOL_ID_ON/ETHTOOL_ID_OFF
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
> 
> Stephen,
> 
> This worked fine as is.
> Thanks,
> Ron Mercer
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied, thanks everyone.
