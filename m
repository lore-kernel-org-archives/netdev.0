From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next 2/2] tc: cls_bpf: rename bpf_len to bpf_num_ops
Date: Wed, 14 Jan 2015 13:12:17 +0100
Message-ID: <54B65D21.5070802@redhat.com>
References: <1421229297-14473-1-git-send-email-jiri@resnulli.us> <1421229297-14473-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	ast@plumgrid.com, hannes@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872AbbANMMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 07:12:30 -0500
In-Reply-To: <1421229297-14473-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 10:54 AM, Jiri Pirko wrote:
> It was suggested by DaveM to change the name as "len" might indicate
> unit bytes.
>
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Fine by me.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
