From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: ne driver crashes when unloaded in 2.6.22.6
Date: Wed, 12 Sep 2007 19:23:36 +0100 (BST)
Message-ID: <313644.18131.qm@web52907.mail.re2.yahoo.com>
References: <1189459880.15229.18.camel@xo-3E-67-34.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52907.mail.re2.yahoo.com ([206.190.49.17]:25272 "HELO
	web52907.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965052AbXILSXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:23:41 -0400
In-Reply-To: <1189459880.15229.18.camel@xo-3E-67-34.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Dan Williams <dcbw@redhat.com> wrote:
> > > Offhand question, does your ne2000 card support carrier detection?
> > 
> > Err... there is a /sys/class/net/eth0/carrier entry 
> 
> Does it read '0' when you unplug the cable?

Hmm, apparently not. The light on the card goes out though, so could this just be a lack of driver
support?

Cheers,
Chris



      ___________________________________________________________
Yahoo! Answers - Got a question? Someone out there knows the answer. Try it
now.
http://uk.answers.yahoo.com/ 
