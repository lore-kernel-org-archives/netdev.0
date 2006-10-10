From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx scan oops!!!
Date: Tue, 10 Oct 2006 23:06:16 +0200
Message-ID: <200610102306.16143.mb@bu3sch.de>
References: <452B1015.6040104@nctv.com> <200610101217.55909.mb@bu3sch.de> <452BACF2.60900@nctv.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41191
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030393AbWJJVGh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 17:06:37 -0400
To: "Jory A. Pratt" <anarchy@nctv.com>
In-Reply-To: <452BACF2.60900@nctv.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 10 October 2006 16:23, Jory A. Pratt wrote:
> Michael Buesch wrote:
> > On Tuesday 10 October 2006 05:14, Jory A. Pratt wrote:
> >   
> >> http://home.nctv.com/anarchy/dscape-clean.jpg
> >>     
> >
> > That's hardly readable.
> > But which firmware are you running? v4.x by chance?
> >
> >   
> Just for completeness I just tested with v4.x firmware and still get the 
> panic

4.x firmware won't work. Make sure to use 3.x.

I am not sure what happens.
Any chance to get a more complete oops message? I am also interrested
in the start of the oops message. In particular I would like to see if this
is a NULL pointer bug, machine check or something else.
The backtrace is a little big weird. So I am not sure what happens.

And, Please make _really_ sure to use 3.x firmware. ;)

-- 
Greetings Michael.
