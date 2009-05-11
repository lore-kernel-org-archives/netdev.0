From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Putting for discussion "__qdisc_run" bug - strange application-dependant
 error
Date: Mon, 11 May 2009 18:34:39 +0200
Message-ID: <4A08539F.8080904@gmail.com>
References: <657221.87331.qm@web28608.mail.ukl.yahoo.com> <4A06834A.1040307@gmail.com> <315332.14155.qm@web28609.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Panadero Pizza <panadero_pizza@yahoo.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:58101 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460AbZEKQfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 12:35:09 -0400
Received: by bwz22 with SMTP id 22so2762031bwz.37
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 09:35:09 -0700 (PDT)
In-Reply-To: <315332.14155.qm@web28609.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Panadero Pizza wrote, On 05/11/2009 01:33 PM:

> 
> De: Jarek Poplawski
> 
>> Since you're suggesting the specific patch has broken this for you, could
> 
>> you simply write if 2.6.24.4 (or 2.6.24.7 with "NET: Add preemption point
>> in qdisc_run" patch reverted) also solves your problem?
> 
> I'm now testing the 2.6.24.7 kernel with CONFIG_PREEMPT_NONE.
> (If I knew how to easily revert the patch for the __qdisc_run function,
> I would like to test it, too) ... 

You can try 2.6.24.4 which doesn't have this patch. But I doubt this
patch really matters here.

Jarek P.
