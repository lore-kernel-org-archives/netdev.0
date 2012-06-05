From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Reoccuring kern.log events after running xl2tp with ethernet adapter Realtek 8111E
Date: Tue, 5 Jun 2012 17:37:53 +0200
Message-ID: <20120605153753.GA12514@electric-eye.fr.zoreil.com>
References: <CANcVnzi2mXKXZLcaAt9rJ9OOdK_2=V8JV9uebVeBcsDu6j+DhQ@mail.gmail.com> <CANcVnzivnQrhSderZ+b5yoy+F1OiO7Ajv7WeijqzQKyAkYRqug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dustin Schumm <shodid@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38135 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091Ab2FEPqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 11:46:43 -0400
Content-Disposition: inline
In-Reply-To: <CANcVnzivnQrhSderZ+b5yoy+F1OiO7Ajv7WeijqzQKyAkYRqug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dustin Schumm <shodid@gmail.com> :
[...]
> Forgive me for sending this in plain test as I got a reject from
> netdev for html.

Please:
- no full quote
- no top answer
- no html

Thanks.

[...]
> I've also tested with Fedora 17 using kernel 3.3.7
> http://codepad.org/lxkcRLqp
> This paste is from Fedora. Like Ubuntu, it starts with "general
> protection fault: 0000 [#1] SMP" but does not give the other looping
> messages after as in Ubuntu.

This is with an usual 1500 bytes MTU and without TSO (see 'ethtool -k ethX'),
right ?

-- 
Ueimor
