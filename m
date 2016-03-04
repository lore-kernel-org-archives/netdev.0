From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V2 02/10] net/flow_dissector: Make dissector_uses_key()
 and skb_flow_dissector_target() public
Date: Fri, 04 Mar 2016 08:55:51 -0800
Message-ID: <56D9BE17.8060700@gmail.com>
References: <1457016960-27832-1-git-send-email-amir@vadai.me> <1457016960-27832-3-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36780 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbcCDQ4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:56:07 -0500
Received: by mail-pa0-f65.google.com with SMTP id a7so3283229pax.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 08:56:07 -0800 (PST)
In-Reply-To: <1457016960-27832-3-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-03 06:55 AM, Amir Vadai wrote:
> Will be used in a following patch to query if a key is being used, and
> what it's value in the target object.
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Looks like you might roll a v3 feel free to pull these acks forward
as well.
