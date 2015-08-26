From: David Miller <davem@davemloft.net>
Subject: Re: tcp: add NV congestion control
Date: Tue, 25 Aug 2015 17:19:46 -0700 (PDT)
Message-ID: <20150825.171946.1263373457036222017.davem@davemloft.net>
References: <1440545634-3901299-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com,
	stephen@networkplumber.org, kennetkl@ifi.uio.no
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977AbbHZATs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 20:19:48 -0400
In-Reply-To: <1440545634-3901299-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 25 Aug 2015 16:33:50 -0700

> Changes from v5: cleaning of NV code, changing some default parameters

I have no fundamental objections to this patch series.
