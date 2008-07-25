From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25: WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()
Date: Fri, 25 Jul 2008 15:53:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807251550490.11302@wrl-59.cs.helsinki.fi>
References: <ecb4efd10806231553w8758655xcf861e5e191809ec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Clem Taylor <clem.taylor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55112 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbYGYMxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:53:07 -0400
In-Reply-To: <ecb4efd10806231553w8758655xcf861e5e191809ec@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jun 2008, Clem Taylor wrote:

> My kernel is tainted with both the vmware and nvidia drivers, but I
> thought someone might still care about this.
>
> The system is 2.6.25 x86_64 SMP (with preeempt and tickless).
>
> [841839.294985] ------------[ cut here ]------------
> [841839.294985] WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xdd7/0x22f0()

Please upgrade to at least 2.6.25.7 or 2.6.26, if this still shows up with 
it, then rereport (ccing me of course :-)).


-- 
 i.
