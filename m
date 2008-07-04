From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] support for IEEE 1588
Date: Fri, 04 Jul 2008 13:24:20 +0200
Message-ID: <8763rlsxi3.fsf@basil.nowhere.org>
References: <200807040147.11148.opurdila@ixiacom.com>
	<20080703162428.55d9f345@extreme>
	<200807040240.04801.opurdila@ixiacom.com> <486D6B87.9030409@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:11894 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbYGDLZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 07:25:07 -0400
In-Reply-To: <486D6B87.9030409@hp.com> (Rick Jones's message of "Thu, 03 Jul 2008 17:15:03 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones <rick.jones2@hp.com> writes:
>
> I've not had a good emily litella moment in at least a week, so I'll
> ask - if the clock in the hardware generating the timestamp and the
> clock in the host aren't synchronized in _some_ way, what benefit is
> there to putting the hardware's timestamp in there?

The point is to synchronize them using a high quality data stamp.

-Andi
