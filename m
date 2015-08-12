From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() loop upper
 bound
Date: Wed, 12 Aug 2015 17:58:53 +0200
Message-ID: <55CB6D3D.9010805@iogearbox.net>
References: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@plumgrid.com,
	xiakaixu@huawei.com
To: Wei-Chun Chao <weichunc@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46228 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbbHLP65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 11:58:57 -0400
In-Reply-To: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2015 04:57 PM, Wei-Chun Chao wrote:
> Verifier rejects programs incorrectly.
>
> Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read()")
> Cc: Kaixu Xia <xiakaixu@huawei.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
