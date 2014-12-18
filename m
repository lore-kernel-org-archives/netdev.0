From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Thu, 18 Dec 2014 15:46:21 +0200
Message-ID: <20141218134621.GA9985@angus-think.lan>
References: <54907619.5080508@gmail.com>
 <20141217115535.3f5198d2@urahara>
 <20141217235627.GA2149@angus-think.lan>
 <54923434.3030209@gmail.com>
 <20141218031257.GA19527@angus-think.lan>
 <5492C7FD.8060603@gmail.com>
 <20141218122329.GA31878@angus-think.lan>
 <5492CC8E.6050108@gmail.com>
 <20141218131653.GA5980@angus-think.lan>
 <5492DAFA.5070001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:57223 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbaLRN4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 08:56:24 -0500
Received: by mail-lb0-f175.google.com with SMTP id u10so1009646lbd.34
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 05:56:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5492DAFA.5070001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2014 at 02:47:38PM +0100, Daniel Borkmann wrote:
> On 12/18/2014 02:16 PM, Vadim Kochan wrote:
> ...
> >The problem that this is huge now but looks better visually, I am
> >thinking also about to possibiliy to show only some part of tree by specified parent id ...
> 
> I definitely like this work!
> 
> Just thinking out loud, what about an output option for tc which is plain
> DOT [1], thus it can be handed over for rendering in tools like graphviz?
> 
> It won't require any dependencies either as it's just plaintext.
> 
>   [1] https://en.wikipedia.org/wiki/DOT_%28graph_description_language%29

Yeah, good idea :-)
