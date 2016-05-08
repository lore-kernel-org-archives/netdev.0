From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 0/6] net sched: Fix broken late binding of
 actions
Date: Sun, 8 May 2016 13:29:05 -0400
Message-ID: <572F7761.2020103@mojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34108 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbcEHR3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:29:13 -0400
Received: by mail-io0-f171.google.com with SMTP id 190so154717989iow.1
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:29:13 -0700 (PDT)
In-Reply-To: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 01:26 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Some actions were broken in allowing for late binding of actions.

Dave, these deserve to go into -stable as well.

cheers,
jamal
