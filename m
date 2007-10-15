From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH V7 0/8] net/bonding: ADD IPoIB support for the bonding
 driver
Date: Mon, 15 Oct 2007 17:56:31 -0400
Message-ID: <4713E20F.9080305@pobox.com>
References: <47138EB7.40703@gmail.com> <4713B006.9090908@pobox.com> <27349.1192480486@death> <4713D28F.3010904@pobox.com> <31162.1192485233@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Moni Shoua <monisonlists@gmail.com>, rdreier@cisco.com,
	netdev@vger.kernel.org, general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755746AbXJOV4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:56:41 -0400
In-Reply-To: <31162.1192485233@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> Jay Vosburgh wrote:
>>> 	Since I see you've just pushed it, do you want a patch to
>>> correct just the two individual things, or would you rather have new
>>> patches?
>>
>> On top of what was just pushed, please.
> 
> 	Ok, I'll figure that out and then rebase the locking stuff on
> top of that.

FWIW Linus just pulled, so you may diff against mainline if you wish.

Whatever is easiest for you...

	Jeff



