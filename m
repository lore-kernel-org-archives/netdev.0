From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/8] textsearch: fix textsearch for case insensitive searching
Date: Tue, 24 Jun 2008 07:56:34 -0700
Message-ID: <b25c3fa70806240756g299f845l905761f77f35068c@mail.gmail.com>
References: <1214034838-1270-1-git-send-email-joonwpark81@gmail.com>
	 <485CB9F6.6050601@trash.net> <20080623232224.GG20815@postel.suug.ch>
	 <4860E838.6090508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>
To: "Patrick McHardy" <kaber@trash.net>, "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.244]:60282 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461AbYFXO4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 10:56:37 -0400
Received: by hs-out-0708.google.com with SMTP id 4so465533hsl.5
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 07:56:37 -0700 (PDT)
In-Reply-To: <4860E838.6090508@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/6/24 Patrick McHardy <kaber@trash.net>:
> Thomas Graf wrote:
>>
>> * Patrick McHardy <kaber@trash.net> 2008-06-21 10:21
>>>
>>> This looks fine to me, although a generic flags argument
>>> would prevent changing all users again next time someone
>>> wants to add a feature. But I'll leave that decision to
>>> Thomas.
>>
>> I agree, I'd favour a general flag for this as well.
>
>
> Joonwoo, if you send me a replacement patch that uses a flag
> instead I'm going to apply the entire series.
>

Patrick, I'll resubmit the patch (maybe tonight) with some comments
which are Thomas mentioned about
Thanks.
