From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 13:11:14 -0700
Message-ID: <20071011131114.774406fc@freepuppy.rosehill>
References: <1192127132.4732.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39912 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754522AbXJKULd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 16:11:33 -0400
In-Reply-To: <1192127132.4732.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 20:25:32 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> Hello all!
> 
> Posting this set of patches again, since there where no reaction last time I sent them.
> 
> Regards,
> Andreas Henriksson
> 


Since there are so many. Please send them as git separate emails to me and
make sure they are in the proper format for importing into git. If you really
want to make it easy, just put them in git yourself and then use 'git formatpatch origin'
so all the formatting is correct.

The current iproute2 git repository is:
	git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
(or symlink git://git.kernel.org/pub/network/iproute2/iproute2.git)


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
