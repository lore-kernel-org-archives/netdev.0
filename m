From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Wed, 17 Feb 2016 06:48:19 -0500
Message-ID: <56C45E03.90304@mojatatu.com>
References: <1455626225-16382-1-git-send-email-jhs@emojatatu.com>
 <56C33E58.9090007@iogearbox.net> <56C4575F.5080609@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35705 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161300AbcBQLsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:48:21 -0500
Received: by mail-io0-f171.google.com with SMTP id g203so33889120iof.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:48:20 -0800 (PST)
In-Reply-To: <56C4575F.5080609@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 06:19 AM, Jamal Hadi Salim wrote:

> Thats how the original code was (and what i tested). I dont have time
> to test right now but i will send an update with your suggestion.
>

My setup was still running so I managed to test it with IFE

cheers,
jamal
