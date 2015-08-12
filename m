From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() loop upper
 bound
Date: Wed, 12 Aug 2015 16:43:13 -0700 (PDT)
Message-ID: <20150812.164313.2165285978444550238.davem@davemloft.net>
References: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, xiakaixu@huawei.com
To: weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbbHLXnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:43:14 -0400
In-Reply-To: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei-Chun Chao <weichunc@plumgrid.com>
Date: Wed, 12 Aug 2015 07:57:12 -0700

> Verifier rejects programs incorrectly.
> 
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read()")
> Cc: Kaixu Xia <xiakaixu@huawei.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
> ---
> 
> v2: better subject line

Applied, thanks.
