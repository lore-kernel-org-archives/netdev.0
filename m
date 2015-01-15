From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [patch net-next v4 1/2] tc: add BPF based action
Date: Thu, 15 Jan 2015 10:42:15 +0800
Message-ID: <54B72907.5030602@cn.fujitsu.com>
References: <1421257404-25452-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jhs@mojatatu.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <hannes@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:25061 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750992AbbAOCmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:42:15 -0500
In-Reply-To: <1421257404-25452-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2015 01:43 AM, Jiri Pirko wrote:
>  
> +config NET_ACT_BPF
> +        tristate "BPF based action"
> +        depends on NET_CLS_ACT
> +        ---help---
> +	  Say Y here to execute BPF code on packets. The BPF code will decide
> +	  if the packet should be dropped of not.

dropped or not ?
