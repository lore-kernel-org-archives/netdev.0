From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V1 02/10] net/flow_dissector: Make
 dissector_uses_key() and skb_flow_dissector_target() public
Date: Thu, 3 Mar 2016 10:40:20 +0100
Message-ID: <20160303094020.GC2105@nanopsycho.orion>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
 <1456997006-18538-3-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35026 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbcCCJkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:40:24 -0500
Received: by mail-wm0-f65.google.com with SMTP id 1so3107161wmg.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:40:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456997006-18538-3-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 03, 2016 at 10:23:18AM CET, amir@vadai.me wrote:
>Will be used in a following patch to query if a key is being used, and
>what it's value in the target object.
>
>Signed-off-by: Amir Vadai <amir@vadai.me>

Acked-by: Jiri Pirko <jiri@mellanox.com>
