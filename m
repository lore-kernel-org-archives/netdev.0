From: Joshua Roys <roysjosh@gmail.com>
Subject: Re: [Bugme-new] [Bug 15507] New: kernel misses 3rd part of tcp handshake
 (ACK), stays in SYN_RECV state
Date: Fri, 19 Mar 2010 07:53:30 -0400
Message-ID: <4BA365BA.4040309@gmail.com>
References: <bug-15507-10286@http.bugzilla.kernel.org/>	 <20100318160103.cc28c367.akpm@linux-foundation.org> <1268953951.2894.194.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f182.google.com ([209.85.210.182]:55179 "EHLO
	mail-yx0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab0CSLxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 07:53:44 -0400
Received: by yxe12 with SMTP id 12so575049yxe.33
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 04:53:43 -0700 (PDT)
In-Reply-To: <1268953951.2894.194.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2010 07:12 PM, Eric Dumazet wrote:
>
> I would say this is expected if httpd server set DEFER_ACCEPT socket
> option.
>
>
>

Gah!  You've got to be kidding :)  If that's what it is, close the 
bug...  and I'll go read some man-pages!

Josh
