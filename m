From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC PATCH 5/6] firewire net: IPv6 support (RFC3146).
Date: Sat, 12 Jan 2013 17:31:57 +0100
Message-ID: <50F18FFD.1080808@gmail.com>
References: <50F17171.3050105@linux-ipv6.org> <20130112162224.10e2aa44@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:55566 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab3ALQcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 11:32:00 -0500
Received: by mail-ee0-f53.google.com with SMTP id c1so1282392eek.26
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 08:31:59 -0800 (PST)
In-Reply-To: <20130112162224.10e2aa44@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This is a bit premature.  At least one thing which is still missing (also
> missing in Stephan's patch from previous week) is the RFC 3146 clause 5
> Configuration ROM entry.
Argh, my fault. I already had it when I began to implement this stuff. 
It got lost somewhere...

No problem, I'll add it.
