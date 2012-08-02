From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ss: report SK_MEMINFO_BACKLOG
Date: Wed, 1 Aug 2012 17:06:43 -0700
Message-ID: <20120801170643.6b288283@nehalam.linuxnetplumber.net>
References: <1343294420.2626.11264.camel@edumazet-glaptop>
	<CAGK4HS-fUp2ZiW9F_ZogOXQo5_2ptcBHT9Y2j25ZaoXrYKnbAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60204 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818Ab2HBAGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 20:06:47 -0400
In-Reply-To: <CAGK4HS-fUp2ZiW9F_ZogOXQo5_2ptcBHT9Y2j25ZaoXrYKnbAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jul 2012 17:29:26 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> On 26 July 2012 02:20, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > linux-3.6-rc1 supports SK_MEMINFO_BACKLOG with commit d594e987c6f54
> > (sock_diag: add SK_MEMINFO_BACKLOG)
> >
> > ss command can display it if provided by the kernel.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
> 
> 
> Thanks Eric. I see now how you fixed this.
> 
> Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> 
> Vijay

Applied (after 3.5.0 release).
