From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 08 Nov 2013 15:42:34 -0800
Message-ID: <1383954154.16391.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527C3942.509@hp.com>
	 <1383876294.9412.136.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527D7320.4050008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:63992 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757706Ab3KHXmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 18:42:36 -0500
Received: by mail-pb0-f52.google.com with SMTP id rr4so2776118pbb.39
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 15:42:35 -0800 (PST)
In-Reply-To: <527D7320.4050008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 15:26 -0800, Rick Jones wrote:
> On 11/07/2013 06:04 PM, Eric Dumazet wrote:
> >
> > It seems you do request randomization, but you do not want it for
> > applications written by innocent people...
> 
> That bind() call is not there to request randomization of the TCP source 
> port.

I was actually doing some kind of humor, I should have added a ;)

Thanks
