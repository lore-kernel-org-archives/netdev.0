From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 20:32:09 -0400
Message-ID: <4AC69B89.5010604@gmail.com>
References: <4AC61505.8030701@gmail.com>	<877hvdbj55.fsf@basil.nowhere.org>	<4AC674A4.2040900@gmail.com> <20091002.154808.137771153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:47853 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbZJCAcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 20:32:09 -0400
Received: by qyk3 with SMTP id 3so1336239qyk.4
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 17:32:12 -0700 (PDT)
In-Reply-To: <20091002.154808.137771153.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
>> Ummm, I was following the suggested practice of breaking it into
>> smaller
>> pieces for review.  This is just the control functions and headers.
>> I've
>> actually completed most of the port, and am champing at the bit.
> 
> We can't review the helper functions and infrastructure properly until
> we can see how they are actually used.
> 
> Seeing how they are used shows us how well they are designed.
> 
> Otherwise asking for a is absolutely pointless as we have no context
> in which to judge the code you're showing us.
> 
Thanks.  I'd hand-split my code into much smaller patches for review.
Now, I know there are patches that are *too* small....

I've merged the several things you've mentioned, and will post it soon
(after making sure it compiles and runs separately).
