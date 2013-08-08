From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: macvtap bug: using smp_processor_id() in preemptible code
Date: Thu, 08 Aug 2013 07:04:29 -0700
Message-ID: <1375970669.4004.93.camel@edumazet-glaptop>
References: <20130807164319.20aa2333@thhw500>
	 <1375889211.4004.28.camel@edumazet-glaptop>
	 <20130808102551.6aa47852@thhw500>
	 <1375968072.4004.92.camel@edumazet-glaptop>
	 <20130808155634.239dbc2d@thhw500>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Huth <thuth@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47169 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965292Ab3HHOEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 10:04:31 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so3511203pab.29
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 07:04:31 -0700 (PDT)
In-Reply-To: <20130808155634.239dbc2d@thhw500>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 15:56 +0200, Thomas Huth wrote:

> This patch now silences all error messages! Great, thank you very much!
> If you submit this patch, you can add my
>  Tested-by: Thomas Huth <thuth@linux.vnet.ibm.com>
> if you like.

Sure, I'll send a proper/official patch asap, thanks !
