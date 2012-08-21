From: John Eaglesham <linux@8192.net>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Tue, 21 Aug 2012 15:21:16 -0700
Message-ID: <503409DC.5010001@8192.net>
References: <4FF27CA0.7030708@8192.net> <20120702.221425.418792617776598841.davem@davemloft.net> <4FF2853D.9070707@8192.net> <20120702.224351.1587084404665143719.davem@davemloft.net> <CAPc2XZDHBPKEM+WsWTL+9N_sfgVhOZAoiY3LU=v-QTCb9eQObQ@mail.gmail.com> <11100.1345576795@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Brookman <jeremy.brookman@gmail.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.dfw.emailsrvr.com ([67.192.241.121]:54368 "EHLO
	smtp121.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab2HUWbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 18:31:33 -0400
In-Reply-To: <11100.1345576795@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/21/2012 12:19 PM, Jay Vosburgh wrote:
> Jeremy Brookman <jeremy.brookman@gmail.com> wrote:
>
>>> You should use a mix of tabs, as necessary, to get things to line up
>>> how I told you they need to line up.
>>
>> Unless I'm missing something, this change doesn't seem to have made it
>> through to the kernel tip, but we could really use this bugfix. Is it
>> in a repository I didn't notice, or not yet through the review?  If
>> it's not through the review, is any help needed to get it there?
>
> 	The submitter (John Eaglesham) never posted an updated version
> that addressed the various comments, nor did his original patch
> submission include a Signed-off-by.
>
> 	I went ahead and updated the patch to address the comments; I've
> only compile tested this.  Are you (Jeremy or John) able to test this to
> confirm that it will hash ipv6 traffic as expected (I can test it, but
> it won't be today)?
>
> 	John, can you post a Signed-off-by for your patch (really, this
> updated version of your patch)?
>
> 	If John signs off and somebody tests this, I'll post a formal
> submssion with the full commit message.
>
> 	-J
>

Since my last submission I ended up making some changes on my end to 
streamline the logic. I can fold together my patch with yours and test 
them later tonight. If everything looks good I'll post the changes back 
to the list.

Thanks!
John
