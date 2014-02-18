From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH RFC net-next 0/6] 6lowpan: reimplementation of
 fragmentation handling
Date: Tue, 18 Feb 2014 20:58:27 +0100
Message-ID: <20140218195824.GA935@omega>
References: <1392539668-2349-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:42190 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaBRT6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 14:58:44 -0500
Received: by mail-ea0-f178.google.com with SMTP id a15so8299649eae.9
        for <netdev@vger.kernel.org>; Tue, 18 Feb 2014 11:58:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1392539668-2349-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

any suggestions to this patch stack?

I got a:

Tested-by: Martin Townsend <martin.townsend@xsilon.com>

while this time. He is happy that all things works fine now. :-)

Of course I tested it myself with a linux<->linux and linux<->contiki
connection.

If all seems fine. Is there a chance to bring this patch stack mainline?


- Alex
