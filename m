From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH V7 0/8] net/bonding: ADD IPoIB support for the bonding driver
Date: Mon, 15 Oct 2007 14:53:53 -0700
Message-ID: <31162.1192485233@death>
References: <47138EB7.40703@gmail.com> <4713B006.9090908@pobox.com> <27349.1192480486@death> <4713D28F.3010904@pobox.com>
Cc: Moni Shoua <monisonlists@gmail.com>, rdreier@cisco.com,
	netdev@vger.kernel.org, general@lists.openfabrics.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:37399 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760770AbXJOVyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 17:54:03 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9FLrumW008319
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 17:53:56 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FLrtMO147802
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 15:53:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FLrsfJ023816
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 15:53:55 -0600
In-reply-to: <4713D28F.3010904@pobox.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:

>Jay Vosburgh wrote:
>> 	Since I see you've just pushed it, do you want a patch to
>> correct just the two individual things, or would you rather have new
>> patches?
>
>
>On top of what was just pushed, please.

	Ok, I'll figure that out and then rebase the locking stuff on
top of that.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
