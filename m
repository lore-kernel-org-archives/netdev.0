From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 16:16:21 -0400
Message-ID: <1271362581.23780.12.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org, robert@herjulf.net,
	xiaosuo@gmail.com, andi@firstfloor.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:42627 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755339Ab0DOUQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 16:16:27 -0400
Received: by qyk27 with SMTP id 27so2141229qyk.23
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 13:16:27 -0700 (PDT)
In-Reply-To: <4BC741AE.3000108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-15 at 09:41 -0700, Rick Jones wrote:

> IPS (~= RPS) was running on shared FSB HP9000's.  Now, that was also a BSD 
> networking stack with netisrq's and the like.  TOPS (~= RFS) was also run on 
> shared FSB HP9000s, as well as CC-NUMA HP9000s and Integrity systems.  TOPS was 
> implemented in a Streams-based stack tracing its history to a common ancestor 
> with Solaris (Mentat).

Sounds interesting.
Wikipedia information overload. Any arch description of the HP9000? 
Did your scheme use IPIs to message the other CPUs?

cheers,
jamal 

