From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.32-rc7-git1: Reported regressions from 2.6.31
Date: Mon, 16 Nov 2009 23:14:02 -0800
Message-ID: <m1einxipxh.fsf@fess.ebiederm.org>
References: <GUZt44bIwCE.A.vLF.pSdALB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49239 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbZKQHOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 02:14:07 -0500
In-Reply-To: <GUZt44bIwCE.A.vLF.pSdALB@chimera> (Rafael J. Wysocki's message of "Mon\, 16 Nov 2009 23\:33\:23 +0100 \(CET\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Rafael J. Wysocki" <rjw@sisk.pl> writes:

> This message contains a list of some regressions from 2.6.31, for which there
> are no fixes in the mainline I know of.  If any of them have been fixed already,
> please let me know.
>
> If you know of any other unresolved regressions from 2.6.31, please let me know
> either and I'll add them to the list.  Also, please let me know if any of the
> entries below are invalid.
>
> Each entry from the list will be sent additionally in an automatic reply to
> this message with CCs to the people involved in reporting and handling the
> issue.

Not in 2.6.31 but in 2.6.32-rc5 I get a firmware hang from my netxen
nic when I try to bring the link up.  I have reported and was working
with the developer for a while.  I haven't heard anything in the last
week or so.

Eric
