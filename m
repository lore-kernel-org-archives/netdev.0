From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG,NETFILTER] nfqnl_mangle() not requesting enough space for
 bigger reinjected packet.
Date: Tue, 13 May 2008 13:45:13 +0200
Message-ID: <48297F49.8030707@trash.net>
References: <87skx44lfw.fsf@natisbad.org> <482030F0.5010907@trash.net> <874p92br3d.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Debian Kernel Team <debian-kernel@lists.debian.org>,
	Silviu Vlasceanu <silviuvlasceanu@yahoo.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40004 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbYEMLpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 07:45:52 -0400
In-Reply-To: <874p92br3d.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaud Ebalard wrote:
> Hi,
> 
> Patrick McHardy <kaber@trash.net> writes:
> 
>>> To sum it up, all post 2.6.24.4 kernels need the patch (2.6.24.4
>>> included). This includes all 2.6.25.
>> Thanks for the explanation. I'll send it to -stable after running some
>> tests.
> 
> Sorry to bother again but is there a chance you can send it for
> inclusion in 2.6.25.4?


Sorry for the delay, I sent it to -stable a few minutes ago.
