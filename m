From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: ne driver crashes when unloaded in 2.6.22.6
Date: Sun, 9 Sep 2007 23:12:46 +0100 (BST)
Message-ID: <140033.19941.qm@web52911.mail.re2.yahoo.com>
References: <1189374958.6221.4.camel@xo-3E-67-34.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52911.mail.re2.yahoo.com ([206.190.49.21]:21392 "HELO
	web52911.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751915AbXIIWMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 18:12:47 -0400
In-Reply-To: <1189374958.6221.4.camel@xo-3E-67-34.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--- Dan Williams <dcbw@redhat.com> wrote:
> Offhand question, does your ne2000 card support carrier detection?

Err... there is a /sys/class/net/eth0/carrier entry (I think - not in front of that machine right
now). IIRC it said "1" when I read it.

Cheers,
Chris



      ___________________________________________________________
Yahoo! Answers - Got a question? Someone out there knows the answer. Try it
now.
http://uk.answers.yahoo.com/ 
