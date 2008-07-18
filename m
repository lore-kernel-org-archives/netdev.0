From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: The ATN TP4/CLNP Networking Suite for GNU Linux systems
Date: Fri, 18 Jul 2008 14:41:42 -0700
Message-ID: <20080718144142.4b19c7ff@speedy>
References: <105859.20085.qm@web37604.mail.mud.yahoo.com>
	<488108C9.9050605@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: eus@member.fsf.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45472 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774AbYGRVlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 17:41:44 -0400
In-Reply-To: <488108C9.9050605@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a nice documented process for submitting new drivers/protocols, (see Documentation/SubmittingPatches).
Developers really don't like to spend time looking at code in outside sites. You need to format the code
up as a set of patches to the current kernel and send them in email.
