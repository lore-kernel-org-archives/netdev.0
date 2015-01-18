From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 2/2] tc: cls_bpf: rename bpf_len to
 bpf_num_ops
Date: Sat, 17 Jan 2015 23:51:30 -0500 (EST)
Message-ID: <20150117.235130.2228233585897899625.davem@davemloft.net>
References: <1421311960-14744-1-git-send-email-jiri@resnulli.us>
	<1421311960-14744-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, dborkman@redhat.com,
	ast@plumgrid.com, hannes@redhat.com, gaofeng@cn.fujitsu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbAREvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 23:51:32 -0500
In-Reply-To: <1421311960-14744-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 15 Jan 2015 09:52:40 +0100

> It was suggested by DaveM to change the name as "len" might indicate
> unit bytes.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
