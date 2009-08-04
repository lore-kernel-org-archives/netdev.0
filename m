From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/5] Add common socket helpers to unify the security
	hooks
Date: Tue, 4 Aug 2009 14:58:50 -0500
Message-ID: <20090804195850.GA11746@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-4-git-send-email-danms@us.ibm.com> <20090804192036.GC10275@us.ibm.com> <87d47bl60r.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39598 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbZHDT6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 15:58:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74JuxkT024227
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:56:59 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74JwmaZ244216
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:58:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74JwmgQ027524
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:58:48 -0600
Content-Disposition: inline
In-Reply-To: <87d47bl60r.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> My only concern here is whether 0 should be passed in by the
> SH> caller?  (Not sure, just wondering)
> 
> I just figured I'd split up the 0/1 case into getname and getpeer,
> mirroring the libc calls.  I don't care either way.

Oh, sounds sensible.

-serge
