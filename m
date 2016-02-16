From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 4/8] net: add tc offload feature flag
Date: Tue, 16 Feb 2016 21:22:57 +0100
Message-ID: <20160216202257.GD2246@nanopsycho.orion>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
 <20160216060150.32452.39235.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35008 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756000AbcBPUXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:23:00 -0500
Received: by mail-wm0-f44.google.com with SMTP id c200so180769978wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:22:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160216060150.32452.39235.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 07:01:50AM CET, john.fastabend@gmail.com wrote:
>Its useful to turn off the qdisc offload feature at a per device
>level. This gives us a big hammer to enable/disable offloading.
>More fine grained control (i.e. per rule) may be supported later.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
