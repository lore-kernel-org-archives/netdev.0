From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCPCT-1: adding a sysctl
Date: Fri, 02 Oct 2009 15:48:08 -0700 (PDT)
Message-ID: <20091002.154808.137771153.davem@davemloft.net>
References: <4AC61505.8030701@gmail.com>
	<877hvdbj55.fsf@basil.nowhere.org>
	<4AC674A4.2040900@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43627
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756391AbZJBWrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 18:47:49 -0400
In-Reply-To: <4AC674A4.2040900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 02 Oct 2009 17:46:12 -0400

> Andi Kleen wrote:
>> William Allen Simpson <william.allen.simpson@gmail.com> writes:
>>> Any suggestions for improvement?  Or general approval?
>> The patch seems incomplete, can't find callers for most of the new
>> functions.
>> 
> Ummm, I was following the suggested practice of breaking it into
> smaller
> pieces for review.  This is just the control functions and headers.
> I've
> actually completed most of the port, and am champing at the bit.

We can't review the helper functions and infrastructure properly until
we can see how they are actually used.

Seeing how they are used shows us how well they are designed.

Otherwise asking for a is absolutely pointless as we have no context
in which to judge the code you're showing us.
