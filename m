From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [net-next (TAKE 2) 0/4] IPv6 over Firewire
Date: Sun, 10 Feb 2013 11:29:29 +0100
Message-ID: <51177689.4070904@gmail.com>
References: <5117620A.4050005@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	davem@davemloft.net, stefanr@s5r6.in-berlin.de
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:45145 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab3BJK3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 05:29:33 -0500
Received: by mail-ea0-f182.google.com with SMTP id a12so2399051eaa.41
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 02:29:32 -0800 (PST)
In-Reply-To: <5117620A.4050005@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yoshifuji!

thanks for your submission. The first glance looks good to me but I need
to look over your patch set more thoroughly.

Were you able to test your changes against different IP over firewire
implementations? If not, I will test against the existing Linux
implementation, MacOSX and Windows.

Regards,

Stephan
