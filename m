From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 11:08:59 -0500
Message-ID: <4554A41B.50900@hp.com>
References: <45541757.90800@hp.com> <20061110094828.GF8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:10155 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1753611AbWKJQJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:09:00 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061110094828.GF8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Paul Moore <paul.moore@hp.com> 2006-11-10 01:08
> 
> Excellent!

Thanks.

>>   - u32 snd_pid
>>
>>     This is the PID of the client which issued the request.
> 
> In order to avoid confusion it might be better to call it
> "netlink PID" as it is not equal to the process ID.

Good point, I just made the change.  I'll push out another rev of the document
once the rest of the group has had a chance to review the doc.

-- 
paul moore
linux security @ hp
