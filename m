From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [BUG,NETFILTER] nfqnl_mangle() not requesting enough space for bigger reinjected packet.
Date: Tue, 13 May 2008 09:28:22 +0200
Message-ID: <874p92br3d.fsf@natisbad.org>
References: <87skx44lfw.fsf@natisbad.org> <482030F0.5010907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Debian Kernel Team <debian-kernel@lists.debian.org>,
	Silviu Vlasceanu <silviuvlasceanu@yahoo.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:45723 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703AbYEMH3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 03:29:22 -0400
In-Reply-To: <482030F0.5010907@trash.net> (Patrick McHardy's message of "Tue,
	06 May 2008 12:20:32 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Patrick McHardy <kaber@trash.net> writes:

>> To sum it up, all post 2.6.24.4 kernels need the patch (2.6.24.4
>> included). This includes all 2.6.25.
>
> Thanks for the explanation. I'll send it to -stable after running some
> tests.

Sorry to bother again but is there a chance you can send it for
inclusion in 2.6.25.4?

Cheers,

a+

