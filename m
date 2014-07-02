From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] net: arcnet: Remove "#define bool int"
Date: Wed, 02 Jul 2014 19:49:17 +0200
Message-ID: <87oax7mz1e.fsf@rasmusvillemoes.dk>
References: <1404303121-2548-1-git-send-email-linux@rasmusvillemoes.dk>
	<20140702160250.GA2658@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140702160250.GA2658@kroah.com> (Greg Kroah-Hartman's message
	of "Wed, 2 Jul 2014 09:02:50 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:

> On Wed, Jul 02, 2014 at 02:12:01PM +0200, Rasmus Villemoes wrote:
>
>>  include/linux/arcdevice.h | 10 +++-------
>>  1 file changed, 3 insertions(+), 7 deletions(-)
>
> Why are you sending this patch to me?  I don't "own" it at all, please
> use scripts/get_maintainer.pl to determine who to email patches to.

Sorry. I did use get_maintainer.pl, but that only produced the two
mailing lists. I thought one was supposed to include at least one
maintainer, so I made a (not-so-)educated guess. I'll try to be more
careful in the future.

Rasmus
