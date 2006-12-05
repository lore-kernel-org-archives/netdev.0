From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 1/7] Sync with 2.6.19 kernel header about include/linux.
Date: Tue, 05 Dec 2006 21:27:08 +0900
Message-ID: <4575659C.6050904@linux-ipv6.org>
References: <11653137213434-git-send-email-nakam@linux-ipv6.org> <20061205104211.GW8693@postel.suug.ch> <45755BB5.2060707@linux-ipv6.org> <20061205115415.GY8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:49027 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S968189AbWLEM1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 07:27:10 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061205115415.GY8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
>>> Why are you reverting this?
>> I just update the header about include/linux without thinking.
>> Should I have to update them except fib_rules.h?
> 
> The iproute2 git tree already contains patches for the
> 2.6.20 release.

OK, thanks. Can you know another patch which is already
updated to newer version except fib_fules.h, iprule.c?

Regards,

-- 
Masahide NAKAMURA
