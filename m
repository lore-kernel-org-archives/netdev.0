From: Dan Williams <dcbw@redhat.com>
Subject: Re: ne driver crashes when unloaded in 2.6.22.6
Date: Mon, 10 Sep 2007 17:31:20 -0400
Message-ID: <1189459880.15229.18.camel@xo-3E-67-34.localdomain>
References: <140033.19941.qm@web52911.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbXIJVcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 17:32:05 -0400
In-Reply-To: <140033.19941.qm@web52911.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-09-09 at 23:12 +0100, Chris Rankin wrote:
> --- Dan Williams <dcbw@redhat.com> wrote:
> > Offhand question, does your ne2000 card support carrier detection?
> 
> Err... there is a /sys/class/net/eth0/carrier entry (I think - not in front of that machine right
> now). IIRC it said "1" when I read it.

Does it read '0' when you unplug the cable?

Dan

> Cheers,
> Chris
> 
> 
> 
>       ___________________________________________________________
> Yahoo! Answers - Got a question? Someone out there knows the answer. Try it
> now.
> http://uk.answers.yahoo.com/ 

