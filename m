From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver timeout problems
Date: Thu, 14 Sep 2006 14:46:08 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FB4F@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <6315074.post@talk.nabble.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:51463 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751193AbWINVqU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 17:46:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <6315074.post@talk.nabble.com>
To: "sunny12" <johanhen@yahoo.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sunny12 wrote:
> Thanks a lot Michael, it seems to have resolved the issue, at 
> least we were
> not able to reproduce it again
> after changing this flag. I will update this thread if the 
> issue reoccurs.

That's good to know.  When you upgrade to the next 2.6.18
kernel, you can re-enable TSO because the latest driver has
the workaround for this problem.

