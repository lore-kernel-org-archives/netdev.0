From: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Subject: RE: [E1000-devel] i217-LM boot wreckage
Date: Wed, 26 Mar 2014 17:42:42 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9370D01E4@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
 <2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
 <alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
 <D38E8E86660E514AB505863C19C9287C73F87D2B@ORSMSX102.amr.corp.intel.com>
 <2B0E3F215D1AB84DA946C8BEE234CCC9370CF4AB@ORSMSX101.amr.corp.intel.com>
 <alpine.DEB.2.02.1403211657110.18573@ionos.tec.linutronix.de>
 <2B0E3F215D1AB84DA946C8BEE234CCC9370CF6D9@ORSMSX101.amr.corp.intel.com>
 <alpine.DEB.2.02.1403212256540.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41923 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbaCZRoe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 13:44:34 -0400
In-Reply-To: <alpine.DEB.2.02.1403212256540.18573@ionos.tec.linutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just an update.  A patch for this issue was submitted into our internal queue on Monday and is in review/testing.

Dave Ertman

-----Original Message-----
From: Thomas Gleixner [mailto:tglx@linutronix.de] 
Sent: Friday, March 21, 2014 3:01 PM
To: Ertman, DavidX M
Cc: Ronciak, John; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
Subject: RE: [E1000-devel] i217-LM boot wreckage

On Fri, 21 Mar 2014, Ertman, DavidX M wrote:

> I have discovered the cause of this issue.  It is related to the 
> change in the application of a Si errata workaround.
> 
> I will be working on grok'ing the total impact of this issue and 
> writing up the patch over the weekend and will have something pushed 
> into our internal queue early next week.

Take your time and don't spoil your weekend!

It's not a show stopper, as we know how to work around the issue.

If you need testing of some early patch or help with gathering information, let me know. We have 4 reproducer systems handy.

Thanks,

	tglx
