From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Fri, 18 Oct 2013 06:42:37 -0400
Message-ID: <5261109D.5030501@mojatatu.com>
References: <525C62D5.3090004@mojatatu.com>	 <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>	 <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>	 <525ED1AE.7050101@mojatatu.com> <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com> <525EE00A.20209@redhat.com> <525EE2AC.50002@mojatatu.com> <525EF4E7.1030003@mojatatu.com> <525EF570.3050105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:61683 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab3JRKms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 06:42:48 -0400
Received: by mail-ie0-f182.google.com with SMTP id as1so6269826iec.13
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 03:42:47 -0700 (PDT)
In-Reply-To: <525EF570.3050105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/13 16:22, Vlad Yasevich wrote:

> Yes, I know about that one.  BRIDGE_FLAGS started the polution and then
> we continued it with the other attributes....
>

Understood - note the email has subject TheLinuxWay ;->
So i fear this one also falls under "it is already in the wild, cant do
anything about it".

BTW: the flooding and learning knobs are still not exposed to iproute2.

In regards to a GET always being translated to DUMP forcing user space
to filter:
If neither you nor Stephen planning to take of it, I will because it
is a scaling problem.  Please let me know.


cheers,
jamal
