From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 net 2/6] openvswitch: Fix skb leak in ovs_fragment()
Date: Tue, 6 Oct 2015 17:12:08 +0300
Message-ID: <5613D6B8.2080006@cogentembedded.com>
References: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
 <1444083799-57090-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pshelar@nicira.com
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34868 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbJFOMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 10:12:10 -0400
Received: by lacdq7 with SMTP id dq7so2423377lac.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 07:12:09 -0700 (PDT)
In-Reply-To: <1444083799-57090-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/6/2015 1:23 AM, Joe Stringer wrote:

> If ovs_fragment() was unable to fragment the skb due to an L2 header
> that exceeds the supported length, skbs would be leaked. Fix the bug.
>
> Fixes: 7f8a436 "openvswitch: Add conntrack action"

    12-digit SHA1 needed here. And parens along with double quotes as well.

> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

MBR, Sergei
