From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/2] tcp: add NV congestion control
Date: Thu, 19 May 2016 11:50:02 -0700 (PDT)
Message-ID: <20160519.115002.2299349000280786986.davem@redhat.com>
References: <1463534736-2739015-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com,
	stephen@networkplumber.org, kennetkl@ifi.uio.no
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527AbcESSuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 14:50:05 -0400
In-Reply-To: <1463534736-2739015-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 17 May 2016 18:25:34 -0700

> This patchset adds support for NV congestion control.
> 
> This version of NV does much better than previous versions when things are
> very congested. 
> 
> Tested in a rack using between 1 and 380 active TCP-NV flows.
> 
> Consists of the following patches:
> [PATCH net-next 1/2] tcp: add in_flight to tcp_skb_cb
> [PATCH net-next 2/2] tcp: add NV congestion control
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Sorry this is too late for the current merge window, please resubmit when
the net-next tree opens back up.
