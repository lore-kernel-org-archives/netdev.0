From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Tue, 20 Oct 2015 11:42:19 -0700
Message-ID: <1445366539.22974.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56261092.7080003@oracle.com>
	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56264596.90104@oracle.com>
	 <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5626887D.5050308@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33219 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbbJTSmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 14:42:21 -0400
Received: by pabrc13 with SMTP id rc13so28817339pab.0
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 11:42:20 -0700 (PDT)
In-Reply-To: <5626887D.5050308@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-20 at 19:31 +0100, Alan Burlison wrote:

> No, the race issue with file descriptor reuse and the close() behaviour 
> are not the same thing. The manpage comment is correct, but not relevant.

Ok, it seems you know better than me, I will be stop the discussion and
wait for your patches.
