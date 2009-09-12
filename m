From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Sat, 12 Sep 2009 17:49:01 -0400
Message-ID: <1252792141.25158.68.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
	 <313388.35529.qm@web111617.mail.gq1.yahoo.com>
	 <1252534266.4119.5.camel@dogo.mojatatu.com>
	 <204967.7557.qm@web111613.mail.gq1.yahoo.com>
	 <1252671940.25158.5.camel@dogo.mojatatu.com>
	 <510605.34044.qm@web111611.mail.gq1.yahoo.com>
	 <1252704524.25158.42.camel@dogo.mojatatu.com>
	 <463375.95638.qm@web111612.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.221.181]:32772 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbZILVv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 17:51:29 -0400
Received: by qyk11 with SMTP id 11so1764157qyk.1
        for <netdev@vger.kernel.org>; Sat, 12 Sep 2009 14:51:32 -0700 (PDT)
In-Reply-To: <463375.95638.qm@web111612.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-09-12 at 09:01 -0700, Xiaofei Wu wrote:

> I can mirror the packets (A -> B) to D. Node D forwards them to C.
> Sometimes the same packets through the path A-B-C, A-D-C are not lost. Node C will receive the
> same packets twice. How to handle the duplicate packet on node C ?
> 
> Maybe the duplicate packets have side effects to TCP.
> 

I will leave this to you. This is where you go and do interesting
things, publish your results and maybe write a paper.
I dont think its a big deal to receive duplicate packets.

cheers,
jamal


