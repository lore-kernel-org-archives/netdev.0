From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] tcp: move tcp_update_cwnd_in_recovery
Date: Mon, 03 Sep 2012 14:34:26 -0400 (EDT)
Message-ID: <20120903.143426.2014939689917601176.davem@davemloft.net>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
	<1346643484-12947-2-git-send-email-ycheng@google.com>
	<CADVnQy=RH=3bGhfiKpMBCY-6n16FY9iSXBRWDbbT7h+5FbKKWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, nanditad@google.com, mattmathis@google.com,
	edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174Ab2ICSe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 14:34:29 -0400
In-Reply-To: <CADVnQy=RH=3bGhfiKpMBCY-6n16FY9iSXBRWDbbT7h+5FbKKWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 2 Sep 2012 23:57:02 -0400

> On Sun, Sep 2, 2012 at 11:38 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> To prepare replacing rate halving with PRR algorithm in CWR state.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied to net-next
