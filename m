From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/7] Sync with 2.6.19 kernel header about include/linux.
Date: Tue, 5 Dec 2006 09:34:12 -0800
Message-ID: <20061205093412.6eb0df6a@freekitty>
References: <11653137213434-git-send-email-nakam@linux-ipv6.org>
	<20061205104211.GW8693@postel.suug.ch>
	<45755BB5.2060707@linux-ipv6.org>
	<20061205115415.GY8693@postel.suug.ch>
	<4575659C.6050904@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:55178 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968503AbWLERe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 12:34:26 -0500
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <4575659C.6050904@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 05 Dec 2006 21:27:08 +0900
Masahide NAKAMURA <nakam@linux-ipv6.org> wrote:

> Thomas Graf wrote:
> >>> Why are you reverting this?
> >> I just update the header about include/linux without thinking.
> >> Should I have to update them except fib_rules.h?
> > 
> > The iproute2 git tree already contains patches for the
> > 2.6.20 release.
> 
> OK, thanks. Can you know another patch which is already
> updated to newer version except fib_fules.h, iprule.c?
> 
> Regards,
> 

Rather than apply your patch I am just rerunning my header extract
script against latest 2.6.19-git7 tree

-- 
Stephen Hemminger <shemminger@osdl.org>
