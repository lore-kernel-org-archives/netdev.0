From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Vague maybe ppp-related panic report for 2.6.23-rc9
Date: Thu, 04 Oct 2007 18:59:06 -0700
Message-ID: <adalkai9v9x.fsf@cisco.com>
References: <ada4ph6da05.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:38154 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757844AbXJEB7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 21:59:07 -0400
In-Reply-To: <ada4ph6da05.fsf@cisco.com> (Roland Dreier's message of "Thu, 04 Oct 2007 11:12:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just as a quick update -- I seem to only be able to reproduce this
crash when my ppp session drops, which seems associated with marginal
signal.  And unfortunately I have great coverage at home so I haven't
been able to reproduce this again today.  Maybe on the train tomorrow
I can crash my laptop...

 - R.
