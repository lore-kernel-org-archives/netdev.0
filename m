From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Sat, 5 Sep 2015 10:46:51 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509051044040.15006@nanos>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com> <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com> <alpine.DEB.2.11.1508222143530.3873@nanos> <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
 <alpine.DEB.2.11.1509041438520.15006@nanos> <20150904151021.GF18489@twins.programming.kicks-ass.net> <20150904151743.GB16862@localhost.localdomain> <20150904154133.GI18489@twins.programming.kicks-ass.net> <alpine.DEB.2.11.1509041832440.15006@nanos>
 <B79D786B7111A34A8CF09F833429C493A90B2FDE@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <peterz@infradead.org>,
	Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:57451 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbbIEIru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 04:47:50 -0400
In-Reply-To: <B79D786B7111A34A8CF09F833429C493A90B2FDE@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Sep 2015, Hall, Christopher S wrote:
> > Right, but we still do not know how that is going to be used. And
> > that's the key question. As long as that is not answered all can do is
> > wild guessing.
> 
> It's not wild guessing.  We do have it working on other OSs and have
> a pretty good idea of how it will work.  The DSP firmware will be
> largely identical for Linux.  I think now, we have a chicken and egg
> problem.

You have a totally different problem. You are just refusing to explain
how all that stuff is supposed to work and what kind of functionality
you need exactly.

Is it that hard to describe the technical requirements and the
presumably assbackwards restrictions of the firmware?

Thanks,

	tglx
