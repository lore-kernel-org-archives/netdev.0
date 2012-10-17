From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: Question about Mellanox FW reporting (incorrect) port types
Date: Wed, 17 Oct 2012 16:49:41 -0300
Message-ID: <507F0BD5.7080005@redhat.com>
References: <507EDC5D.4070602@redhat.com> <CAJZOPZ+T7paqVe12n+sBw4ra8AEWCZ+W2GZ52iJY=9Hrgoxuaw@mail.gmail.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Yishai Hadas <yishaih@dev.mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986Ab2JQTt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 15:49:57 -0400
In-Reply-To: <CAJZOPZ+T7paqVe12n+sBw4ra8AEWCZ+W2GZ52iJY=9Hrgoxuaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2012 04:22 PM, Or Gerlitz wrote:
> Marcelo Ricardo Leitner <mleitner@redhat.com> wrote:
>>
>> [...] So my questions are: is it possible to the firmware report a wrong port type like
>> that? Is it somehow configurable by sysadmin (via fw update, ..), can we flip that byte
>> or is it a manufacturing issue?
>
>
> I'm not sure, Yevgeny/Yishai do you have any insights here?
>
>> I can't try upstream driver
>
> why?! netdev is dealing with upstream, isn't it?

Yes, it is. By upstream I actually mean a non-RHEL kernel/driver. I 
tried but so far couldn't reproduce this issue in-house, sorry. My ports 
always answer ETH :) So I have to ask for customer to test and then 
unfortunately things get complicated..

Thanks,
Marcelo
