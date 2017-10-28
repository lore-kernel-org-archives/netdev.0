From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH v2 net-next 2/3] net: Add extack to fib_notifier_info
Date: Sat, 28 Oct 2017 16:54:16 +0300
Message-ID: <20171028135416.GA25120@splinter>
References: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
 <1509151034-28278-3-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        johannes.berg@intel.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48933 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751270AbdJ1NyT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 09:54:19 -0400
Content-Disposition: inline
In-Reply-To: <1509151034-28278-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 05:37:13PM -0700, David Ahern wrote:
> Add extack to fib_notifier_info and plumb through stack to
> call_fib_rule_notifiers, call_fib_entry_notifiers and
> call_fib6_entry_notifiers. This allows notifer handlers to
> return messages to user.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
