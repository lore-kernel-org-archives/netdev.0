From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] MAINTAINERS: remove Adam Fritzler, update his email address in other sources
Date: Tue, 18 Dec 2007 06:43:15 -0700
Message-ID: <20071218134128.GB5785@parisc-linux.org>
References: <1197951126.4891.13.camel@localhost> <20071217202800.1c898441.akpm@linux-foundation.org> <1197953283.4891.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Adam Fritzler <mid@zigamorph.net>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Mike Phillips <mikep@linuxtr.net>,
	Philip Blundell <philb@gnu.org>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:41272 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003AbXLRNoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 08:44:54 -0500
Content-Disposition: inline
In-Reply-To: <1197953283.4891.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 08:48:03PM -0800, Joe Perches wrote:
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 9507b42..690f172 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3758,13 +3758,6 @@ W:	http://www.kernel.org/pub/linux/kernel/people/bunk/trivial/
>  T:	git kernel.org:/pub/scm/linux/kernel/git/bunk/trivial.git
>  S:	Maintained
>  
> -TMS380 TOKEN-RING NETWORK DRIVER
> -P:	Adam Fritzler
> -M:	mid@auk.cx
> -L:	linux-tr@linuxtr.net
> -W:	http://www.auk.cx/tms380tr/
> -S:	Maintained

That's pretty unfriendly.  Presumably the linux-tr list is still active
and would still help people with that driver.  So how about:

 TMS380 TOKEN-RING NETWORK DRIVER
-P:   Adam Fritzler
-M:   mid@auk.cx
 L:   linux-tr@linuxtr.net
?W:?
-S:   Maintained
+S:   Orphan

(Dunno what to do about W:)

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
