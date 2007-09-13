From: Dan Williams <dcbw@redhat.com>
Subject: Re: ne driver crashes when unloaded in 2.6.22.6
Date: Thu, 13 Sep 2007 00:02:43 -0400
Message-ID: <1189656163.30762.3.camel@xo-3E-67-34.localdomain>
References: <313644.18131.qm@web52907.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbXIMEDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:03:46 -0400
In-Reply-To: <313644.18131.qm@web52907.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 19:23 +0100, Chris Rankin wrote:
> --- Dan Williams <dcbw@redhat.com> wrote:
> > > > Offhand question, does your ne2000 card support carrier detection?
> > > 
> > > Err... there is a /sys/class/net/eth0/carrier entry 
> > 
> > Does it read '0' when you unplug the cable?
> 
> Hmm, apparently not. The light on the card goes out though, so could this just be a lack of driver
> support?

Likely, yes.

dan


> Cheers,
> Chris
> 
> 
> 
>       ___________________________________________________________
> Yahoo! Answers - Got a question? Someone out there knows the answer. Try it
> now.
> http://uk.answers.yahoo.com/ 

