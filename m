From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] infiniband: fix for NIPQUAD removal
Date: Sat, 10 Jan 2009 21:46:28 -0800
Message-ID: <aday6ximm2z.fsf@cisco.com>
References: <1231651594.5714.65.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:12749 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbZAKFqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 00:46:30 -0500
In-Reply-To: <1231651594.5714.65.camel@brick> (Harvey Harrison's message of
	"Sat, 10 Jan 2009 21:26:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

applied, thanks a lot for fixing this.

any further work you want to do in cleaning up some of the endian mess
in this driver would be gratefully received :)

 - R.
