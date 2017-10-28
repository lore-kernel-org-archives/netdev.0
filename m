From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: prevent user from adding cached routes
Date: Sat, 28 Oct 2017 10:25:56 -0700
Message-ID: <20171028172556.wc6wb2iibidw4sir@kafai-mbp>
References: <20171028003012.15609-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36744 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751342AbdJ1R0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 13:26:08 -0400
Content-Disposition: inline
In-Reply-To: <20171028003012.15609-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 05:30:12PM -0700, Wei Wang wrote:
> So we fix this by failing the attemp to add cached routes from userspace
> with returning EINVAL error.
Acked-by: Martin KaFai Lau <kafai@fb.com>
