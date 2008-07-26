From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] netns: fix ip_rt_frag_needed rt_is_expired
Date: Sat, 26 Jul 2008 20:26:39 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0807262025010.10215@blonde.site>
References: <Pine.LNX.4.64.0807261345400.6643@blonde.site>
 <1217090252.6549.4.camel@iris.sw.ru> <1217099437.6549.6.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Denis V. Lunev" <den@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from extu-mxob-1.symantec.com ([216.10.194.28]:45840 "EHLO
	extu-mxob-1.symantec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbYGZT1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 15:27:15 -0400
In-Reply-To: <1217099437.6549.6.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Jul 2008, Denis V. Lunev wrote:
> On Sat, 2008-07-26 at 20:40 +0400, Denis V. Lunev wrote:
> > Acked-by: Denis V. Lunev <den@openvz.org>
> > 
> > Thanks for founding this issue...
> 
> oops... I mean finding and fixing... my fault again

No problem - and both errors were quite understandable!

Hugh
