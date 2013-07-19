From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: net-next is now OPEN
Date: Fri, 19 Jul 2013 16:27:42 +0300
Message-ID: <51E93ECE.9000108@linux.intel.com>
References: <20130719.023518.589482296695696122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12788 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab3GSN1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jul 2013 09:27:45 -0400
In-Reply-To: <20130719.023518.589482296695696122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/07/2013 12:35, David Miller wrote:
> 
> Please feel free to submit net-next patches now, thanks for being
> so patient.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

In the next couple of weeks, I would like to post changes to epoll that
add busy polling support.

Who should be CC-ed on the patches?

BTW, Right now I'm seeing very good results.
I have tested with up to 10,000 sockets using sockperf.
There are a few more things I want to do before submitting.

Thanks,
Eliezer
