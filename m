From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Fri, 24 Aug 2012 08:32:41 +0200
Message-ID: <20120824063240.GB2212@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <1345777345.16471.18.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36512 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab2HXGcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 02:32:52 -0400
Received: by wicr5 with SMTP id r5so520462wic.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 23:32:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345777345.16471.18.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 08:02:25PM -0700, Joe Perches wrote:

> Improving code clarity and consistency isn't churn.

This patch series moves code around for no good reason. That is, by
definition, churn.

> The most valuable form of code is the current one,
> not any antecedent version.

You really haven't noticed all the code review and rebasing that goes
on around here in order to improve the commit history, have you?

Thanks,
Richard
