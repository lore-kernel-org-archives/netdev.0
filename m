From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] l2tp: Fix a UDP socket reference count bug in the pppol2tp
 driver
Date: Thu, 11 Feb 2010 11:32:12 +0000
Message-ID: <4B73EABC.5000707@katalix.com>
References: <20100121161009.5223.34288.stgit@bert.katalix.com>	<20100123.015511.83860202.davem@davemloft.net>	<4B603C50.20406@katalix.com> <20100128.060717.99647383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:47543 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699Ab0BKLcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 06:32:24 -0500
In-Reply-To: <20100128.060717.99647383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Wed, 27 Jan 2010 13:14:56 +0000
> 
>> Does the above help?
> 
> Thanks for the detailed explanation, I'll take another look
> at this.

Did you get a chance to look at this?

fyi - I'm getting ready to submit a patch series that adds L2TPv3
support. I've been sitting on these for too long and have finally found
time to prep them for review. Previous version was posted as RFC a year
ago, archived here: http://marc.info/?l=linux-netdev&m=123532490429538&w=2

Should I wait for my previous fix to be reviewed before posting the new
code? Or I could bundle that patch in the series - whichever works for you.

Thanks

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

