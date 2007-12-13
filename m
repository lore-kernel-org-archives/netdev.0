From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 2.6.25] [IPV4] Reduce whitespaces in fib_rules.h.
Date: Thu, 13 Dec 2007 18:01:32 +0300
Message-ID: <4761494C.4000202@sw.ru>
References: <20071213141842.GA9939@iris.sw.ru> <20071213.065045.189743239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:60841 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757336AbXLMPAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 10:00:04 -0500
In-Reply-To: <20071213.065045.189743239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Thu, 13 Dec 2007 17:18:42 +0300
> 
>> There are to many spaces between type and function name in the declaration
>> of fib rules manipulation routines. Eat them and save a couple of lines.
>>
>> Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> This is just noise and serves nothing other than to invite potential
> patch conflicts which makes development harder.
> 
> If you happened to be changing these for other reasons, I'd say OK,
> but not like this.
> 
I will add parameter to these calls. The line will be too long after
that. I'd like to separate sense changes from, you perfectly correct,
useless changes :(

Could you still apply it, or I will need to send fully functional set to
you including this?
