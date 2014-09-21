From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: action stats broken?
Date: Sun, 21 Sep 2014 10:21:55 -0400
Message-ID: <541EDF03.1050307@mojatatu.com>
References: <541D7E55.6070306@mojatatu.com> <541D9B78.8070505@gmail.com> <541EC5A4.9040600@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41208 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaIUOV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:21:59 -0400
Received: by mail-ie0-f178.google.com with SMTP id at20so6087611iec.37
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 07:21:58 -0700 (PDT)
In-Reply-To: <541EC5A4.9040600@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/14 08:33, Jamal Hadi Salim wrote:
> On 09/20/14 11:21, John Fastabend wrote:
>
> I have time this morning - I will chase it to double check in case
> my environment is messed up.
>

There is something wrong for sure.
Ruling out kernel regression at this point.
It is definetely passing the stats.
Zoning on iproute2.

cheers,
jamal
