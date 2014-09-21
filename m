From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: action stats broken?
Date: Sun, 21 Sep 2014 11:01:13 -0400
Message-ID: <541EE839.4010104@mojatatu.com>
References: <541D7E55.6070306@mojatatu.com> <541D9B78.8070505@gmail.com> <541EC5A4.9040600@mojatatu.com> <541EDF03.1050307@mojatatu.com> <541EE5A9.4000207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:62754 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaIUPBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 11:01:17 -0400
Received: by mail-ig0-f179.google.com with SMTP id l13so1455843iga.0
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 08:01:16 -0700 (PDT)
In-Reply-To: <541EE5A9.4000207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/14 10:50, John Fastabend wrote:

> I think you are right might need to bisect iproute2.

I think i may have found it. Broken by a patch i sent
in May.
Working on a fix ..

cheers,
jamal
