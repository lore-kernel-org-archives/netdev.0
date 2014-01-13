From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Mon, 13 Jan 2014 16:31:10 +0100
Message-ID: <20140113153110.GA2499@minipsycho.orion>
References: <20140108200019.GK9007@order.stressinduktion.org>
 <1389227404-12586-1-git-send-email-thaller@redhat.com>
 <20140110.181030.2081631538801450145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thaller@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:57897 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbaAMPbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 10:31:14 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so3400841eae.19
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 07:31:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140110.181030.2081631538801450145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jan 11, 2014 at 12:10:30AM CET, davem@davemloft.net wrote:
>From: Thomas Haller <thaller@redhat.com>
>Date: Thu,  9 Jan 2014 01:30:02 +0100
>
>> v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
>> v2 -> v3: reword commit messages, code comments and some refactoring.
>> v3 -> v4: refactor, rename variables, add enum
>> 
>> Thomas Haller (2):
>>   ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
>>     IP6 routes
>>   ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
>
>Series applied, thanks Thomas.

Hi Dave. Have you pushed this already? I can't see these patches in
net-next.

Thanks
