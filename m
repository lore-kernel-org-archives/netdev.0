From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] ipv4: Make fib_encap_match static
Date: Wed, 19 Aug 2015 13:03:22 +0200
Message-ID: <20150819130322.797f84b1@griffin>
References: <1439971491-16210-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615AbbHSLDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 07:03:25 -0400
In-Reply-To: <1439971491-16210-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 16:04:51 +0800, Ying Xue wrote:
> Make fib_encap_match() static as it isn't used outside the file.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Reviewed-by: Jiri Benc <jbenc@redhat.com>

Noticed that, too, you were faster, again :-)

 Jiri

-- 
Jiri Benc
