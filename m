From: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Wed, 20 Sep 2006 08:44:22 +1000
Message-ID: <04bc01c6dc3d$4bbf6cb0$0b00000a@bluereef.local>
References: <20060906124447.642940bd@localhost.localdomain><01cb01c6d542$88544620$5001010a@bluereef.local> <20060919133159.27165976@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.mud.yahoo.com ([68.142.200.254]:39848 "HELO
	smtp106.biz.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751241AbWISWpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 18:45:19 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not that I've been able to uncover.

Thanks for fixing this..

----- Original Message ----- 
From: "Stephen Hemminger" <shemminger@osdl.org>
To: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Cc: <netdev@vger.kernel.org>
Sent: Wednesday, September 20, 2006 6:31 AM
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix


> On Mon, 11 Sep 2006 11:35:11 +1000
> "Andrew Hall" <andrew.hall@bluereefnetworks.com> wrote:
>
>> Stephen,
>>
>> After some serious testing, this patch seems to fix the lockup issue
>> completely. I manually applied these changes against the 2.6.17.13 
>> release.
>
> Any more problems?
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html 

