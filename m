From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Mon, 12 Jul 2010 18:56:18 +0300
Message-ID: <1278950178.17933.2.camel@localhost.localdomain>
References: <1277659633.2989.2.camel@localhost.localdomain>
	 <1277659785.4028.1.camel@localhost.localdomain>
	 <1277660638.3321.1.camel@localhost.localdomain>
	 <1277660831.3321.3.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	 <1277745247.12841.1.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
	 <1277807529.19417.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
	 <1277938757.4138.3.camel@localhost.localdomain>
	 <1278204106.21020.0.camel@localhost.localdomain>
	 <1278283714.3444.1.camel@localhost.localdomain>
	 <AANLkTin4sdPeExcNJkq4pfwIq0lcJuXtzTAACRW3JTFh@mail.gmail.com>
	 <1278323885.5277.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64972 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997Ab0GLP4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 11:56:24 -0400
Received: by bwz1 with SMTP id 1so2444049bwz.19
        for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 08:56:22 -0700 (PDT)
In-Reply-To: <1278323885.5277.0.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-05 at 12:58 +0300, Maxim Levitsky wrote:
> On Mon, 2010-07-05 at 01:13 -0700, Jeff Kirsher wrote:
> > On Sun, Jul 4, 2010 at 15:48, Maxim Levitsky <maximlevitsky@gmail.com> wrote:
> > > Did few guesses, and now I see that reverting the below commit fixes the
> > > problem.
> > >
> > > "e1000e: Fix/cleanup PHY reset code for ICHx/PCHx"
> > > e98cac447cc1cc418dff1d610a5c79c4f2bdec7f.
> > >
> > >
> > > Best regards,
> > >        Maxim Levitsky
> > >
> > > --
> > 
> > Can you give us till Tuesday to respond?  I know that there are some
> > additional e1000e patches in my queue, which may resolve the issue,
> > but this weekend the power is down to do some infrastructure upgrades
> > which prevents us from doing any investigation.debugging until
> > Tuesday.
> > 
> 
> Sure.
> 
> Best regards,
> 	Maxim Levitsky
> 

Updates?

or 2.6.35 will ship with e0000e ? :-)

I really have very little time to help further with that for now.


Best regards,
	Maxim Levitsky

