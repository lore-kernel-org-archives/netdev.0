From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH] [TIPC]: Changed msg_set_bits params type
Date: Thu, 26 Apr 2007 19:50:42 -0400
Message-ID: <46313AD2.6060809@ericsson.com>
References: <46310443.7090405@ericsson.com> <20070426.144521.98863152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	jon.maloy@donjonn.com, per.liden@ericsson.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr1.ericy.com ([198.24.6.9]:52919 "EHLO imr1.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755286AbXDZXzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 19:55:46 -0400
In-Reply-To: <20070426.144521.98863152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Did you actually run sparse to see what warnings this change
> adds or deletes or are you submitting untested changes?
>
>   
I did, and I am aware that sparse shows several warnings
for TIPC, which we will have to fix this asap, of course.
The patched line did not show up in the warning list, which
along with a full regression test made me conclude that we
didn't introduce a problem, at least. I see now that it
didn't cause a warning before the change either, so I was
probably too quick to try to please people. You can can
ignore the patch if you want to, but it is safe.

///jon

