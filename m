From: Teco Boot <teco@inf-net.nl>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Wed, 14 Aug 2013 10:06:23 +0200
Message-ID: <64621FDB-9618-40A7-82EE-6056156580F6@inf-net.nl>
References: <190D21D2-F86E-46D2-93E8-3050F57FE622@inf-net.nl> <20130813.011550.791636011692333018.davem@davemloft.net> <AFA62E3B-313C-4ECD-BA28-3543635136EE@inf-net.nl> <20130814.005506.502334877600106930.davem@davemloft.net> <F11B8118-B74D-4AA5-B899-0F2C8D33AA29@inf-net.nl>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:42127 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754917Ab3HNIGa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 04:06:30 -0400
Received: by mail-ea0-f173.google.com with SMTP id g10so4637191eak.4
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 01:06:28 -0700 (PDT)
In-Reply-To: <F11B8118-B74D-4AA5-B899-0F2C8D33AA29@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many excuses to send before adding text. Hitted wrong button.

I don't want to enforce something. Nor I want to spam. Nor I want to bypass. I just spend some cycles to get IPv6 with multi-homing work as designed. Subtrees was broken, maybe from day one. I'm glad there is progress.

I also do not want broken fixes in stable. I know what it is. As I posed, I had to deal with broken fixes when testing the subtree fix. I double checked the fix Hannes made, because Hannes asked me to do so. I'm in for doing more work here.

Teco

Op 14 aug. 2013, om 09:59 heeft Teco Boot <teco@inf-net.nl> het volgende geschreven:

> 
> Op 14 aug. 2013, om 09:55 heeft David Miller <davem@davemloft.net> het volgende geschreven:
> 
>> From: Teco Boot <teco@inf-net.nl>
>> Date: Wed, 14 Aug 2013 08:40:46 +0200
>> 
>>> What can I do to make progress? Spam Linus?
>> 
>> Reaching past the maintainer of a subsystem is generally considered
>> extremely inconsiderate and rude.
>> 
>> I would suggest not doing something like that if you have any interest
>> whatsoever in working peacefully with me in the future.
>> 
>> It sounds like you don't want to use logical arguments to convince me
>> that this patch meets -stable criteria, and instead you would like to
>> simply force the issue.
> 
