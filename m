From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv4 net 1/6] openvswitch: Fix typos in CT headers
Date: Wed, 7 Oct 2015 16:33:15 +0300
Message-ID: <56151F1B.6080207@cogentembedded.com>
References: <1444154401-18029-1-git-send-email-joestringer@nicira.com>
 <1444154401-18029-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pshelar@nicira.com
To: Joe Stringer <joestringer@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35927 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbJGNdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 09:33:18 -0400
Received: by lbcao8 with SMTP id ao8so11312948lbc.3
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 06:33:17 -0700 (PDT)
In-Reply-To: <1444154401-18029-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/2015 8:59 PM, Joe Stringer wrote:

> These comments hadn't caught up to their implementations, fix them.
>
> Fixes: 7f8a436eaa2c "openvswitch: Add conntrack action"

    Sigh. Please see Documentation/SubmittingPatches. It should be:

Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")

> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

MBR, Sergei
