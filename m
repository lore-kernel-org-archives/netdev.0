From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Tue, 24 Mar 2015 01:11:21 -0500
Message-ID: <55110009.4020706@akamai.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>	<20150320.132029.103306583158863864.davem@davemloft.net>	<550C5A98.5040305@akamai.com> <20150324.021050.384709317309031128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:53956 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751108AbbCXGLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 02:11:22 -0400
In-Reply-To: <20150324.021050.384709317309031128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2015 01:10 AM, David Miller wrote:
> From: Josh Hunt <johunt@akamai.com>
> Date: Fri, 20 Mar 2015 12:36:24 -0500
>
>> Would it be possible to queue up 355a901e6cf1 (tcp: make connect()
>> mem charging friendly) for stable as well? That is the commit that
>> fixes this problem in the tcp_connect()/tcp_send_syn_data() cases.
>
> Done.
>

Thanks David.
