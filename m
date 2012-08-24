From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Fri, 24 Aug 2012 02:22:34 -0700
Message-ID: <1345800154.16471.20.camel@joe2Laptop>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120823111622.GC2238@netboy.at.omicron.at>
	 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
	 <20120823175335.GB2192@netboy.at.omicron.at>
	 <1345777345.16471.18.camel@joe2Laptop>
	 <20120824063240.GB2212@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46929 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753119Ab2HXJWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 05:22:36 -0400
In-Reply-To: <20120824063240.GB2212@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 08:32 +0200, Richard Cochran wrote:
> On Thu, Aug 23, 2012 at 08:02:25PM -0700, Joe Perches wrote:
> 
> > Improving code clarity and consistency isn't churn.
> 
> This patch series moves code around for no good reason. That is, by
> definition, churn.

For your definition of good.

> > The most valuable form of code is the current one,
> > not any antecedent version.
> 
> You really haven't noticed all the code review and rebasing that goes
> on around here in order to improve the commit history, have you?

That'd be incorrect too.
