From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/1] net sched actions: skbedit add support for
 mod-ing skb pkt_type
Date: Sun, 12 Jun 2016 17:20:50 -0400
Message-ID: <575DD232.2070602@mojatatu.com>
References: <1465765942-24679-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33221 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbcFLVVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 17:21:07 -0400
Received: by mail-io0-f194.google.com with SMTP id 5so14673208ioy.0
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 14:21:07 -0700 (PDT)
In-Reply-To: <1465765942-24679-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-12 05:12 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Extremely useful for setting packet type to host so i dont
> have to modify the dst mac address using pedit (which requires
> that i know the mac address)
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Please ignore this version; dumping was buggy. Sending a new version
in a minute.

cheers.
jamal
