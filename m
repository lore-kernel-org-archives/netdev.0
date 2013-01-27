From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Sun, 27 Jan 2013 19:20:20 +0100
Message-ID: <51056FE4.50801@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com> <20130121083957.6e2c5a68@stein> <50FD962B.8020500@gmail.com> <50FD9DB7.60802@linux-ipv6.org> <50FDB039.2070604@gmail.com> <20130127154332.6b5730f9@stein> <5105621F.4040408@gmail.com>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64851 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419Ab3A0SUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 13:20:24 -0500
Received: by mail-bk0-f46.google.com with SMTP id j5so971482bkw.5
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 10:20:23 -0800 (PST)
In-Reply-To: <5105621F.4040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Then I'll implement the IPv6 stuff based on that IPv4 solution.
>
> Regards and many thanks for the discussion especially to Yoshifuji.
>

One last question: shall I use net or net-next?

Stephan
