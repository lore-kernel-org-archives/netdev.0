From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Tue, 9 Mar 2010 10:22:02 -0800 (PST)
Message-ID: <9847503.232911268158922219.JavaMail.root@tahiti.vyatta.com>
References: <76131268155285@webmail84.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "\\\"Oleg A. Arkhangelsky\\" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59923 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113Ab0CISWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 13:22:16 -0500
In-Reply-To: <76131268155285@webmail84.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru> wrote:

> Hello, Eric
> 
> >  > Mar  9 10:08:55 bras-1 kernel:
> >  > Mar  9 10:08:55 bras-1 kernel: Pid: 0, comm: swapper Not tainted
> (2.6.32 #3)
> >  
> >  Is it an unpatched kernel ?
> 
> Yes. Vanilla 2.6.32. We saw the same issue on at least 2.6.30.1 (as
> far as I know).
> 


iptables NETFLOW and ISG modules aren't in standard kernel (yet)
   http://www.progtech.ru/~oleg/lISG/
