From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tcp: move tcp_enter_cwr()
Date: Mon, 03 Sep 2012 14:34:17 -0400 (EDT)
Message-ID: <20120903.143417.1202039359059889797.davem@davemloft.net>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
	<CADVnQymfu8YdGT_Rc0GBQ5wzncVQi6-BmTLtzD3MwQV8A3WFUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, nanditad@google.com, mattmathis@google.com,
	edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab2ICSeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 14:34:22 -0400
In-Reply-To: <CADVnQymfu8YdGT_Rc0GBQ5wzncVQi6-BmTLtzD3MwQV8A3WFUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 2 Sep 2012 23:56:09 -0400

> On Sun, Sep 2, 2012 at 11:38 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> To prepare replacing rate halving with PRR algorithm in CWR state.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied to net-next
