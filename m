From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [ofa-general] Re: [PATCH V6 0/9] net/bonding: ADD IPoIB support for the bonding driver
Date: Tue, 02 Oct 2007 11:10:19 -0700
Message-ID: <23084.1191348619@death>
References: <46F7D770.4090500@voltaire.com> <10376.1190733869@death> <470268A2.7080102@gmail.com> <4702773E.4090201@pobox.com>
Cc: Moni Shoua <monisonlists@gmail.com>, netdev@vger.kernel.org,
	Roland Dreier <rdreier@cisco.com>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:42281 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbXJBSKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 14:10:48 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l92IAc4v031110
	for <netdev@vger.kernel.org>; Tue, 2 Oct 2007 14:10:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92IAOe2136088
	for <netdev@vger.kernel.org>; Tue, 2 Oct 2007 12:10:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92IANBQ031164
	for <netdev@vger.kernel.org>; Tue, 2 Oct 2007 12:10:24 -0600
In-reply-to: <4702773E.4090201@pobox.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:

>Moni Shoua wrote:
>> Jay Vosburgh wrote:
>>> ACK patches 3 - 9.
>>>
>>> 	Roland, are you comfortable with the IB changes in patches 1 and 2?
>>>
>>> 	Jeff, when Roland acks patches 1 and 2, please apply all 9.
>>>
>>> 	-J
>>
>> Hi Jeff,
>> Roland acked the IPoIB patches. If you haven't done so already can you please apply them?
>> I'm not sure when 2.6.24 is going to open and I'm afraid to miss it.
>
>hrm, I don't see them in my inbox for some reason.  can someone bounce
>them to me?  or give me a git tree to pull from?

	Moni, can you repost the patch series to Jeff, and put the
appropriate "Acked-by" lines in for myself (patches 3 - 8) and Roland
(patches 1 and 2)?  You can probably leave off the netdev and
openfabrics lists, but cc me.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
