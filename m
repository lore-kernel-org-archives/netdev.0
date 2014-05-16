From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: pch_gbe depends on x86_32
Date: Fri, 16 May 2014 10:26:24 -0700
Message-ID: <1400261184.7973.223.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516112904.7072da0f@endymion.delvare>
	 <1400246161.7973.162.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516.130558.261976058112825591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org, jslaby@suse.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33835 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbaEPR01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:26:27 -0400
Received: by mail-pa0-f45.google.com with SMTP id ey11so2819901pad.32
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:26:27 -0700 (PDT)
In-Reply-To: <20140516.130558.261976058112825591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 13:05 -0400, David Miller wrote:

> That's what COMPILE_TEST is supposed to be for and it's still there :)

Ah nice, I missed this feature, thanks ;)
