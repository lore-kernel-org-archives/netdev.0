From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 4/8] net: add tc offload feature flag
Date: Wed, 17 Feb 2016 06:01:10 -0500
Message-ID: <56C452F6.1070306@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051737.17139.5230.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38050 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422641AbcBQLBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:01:13 -0500
Received: by mail-ig0-f171.google.com with SMTP id y8so12297605igp.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:01:12 -0800 (PST)
In-Reply-To: <20160217051737.17139.5230.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 12:17 AM, John Fastabend wrote:
> Its useful to turn off the qdisc offload feature at a per device
> level. This gives us a big hammer to enable/disable offloading.
> More fine grained control (i.e. per rule) may be supported later.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
