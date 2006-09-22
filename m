From: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Fri, 22 Sep 2006 18:40:00 +1000
Message-ID: <08f701c6de22$b25420b0$0b00000a@bluereef.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.mud.yahoo.com ([68.142.200.252]:28306 "HELO
	smtp104.biz.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751008AbWIVIj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 04:39:56 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> If there's anything I can do to help isolate this issue please let me 
> know.
>

Looking through the logs I'm also intermittently seeing some of this:

sky2 eth1: rx error, status 0x7ffc0001 length 844

I'm not sure if it's related to the TX issue but I thought I'd mention it.

