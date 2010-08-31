From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 16:18:59 +0800
Message-ID: <20100831081859.GA29281@gondor.apana.org.au>
References: <20100830062755.GA22396@verge.net.au> <87k4n8ow1r.fsf@benpfaff.org> <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com> <20100830183328.GI7629@nicira.com> <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com> <20100830205907.GM30129@sequoia.sous-sol.org> <20100831004827.GE11594@verge.net.au> <20100831005410.GB30129@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50746 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097Ab0HaITK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 04:19:10 -0400
Content-Disposition: inline
In-Reply-To: <20100831005410.GB30129@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 05:54:10PM -0700, Chris Wright wrote:
>
> I'll let Herbert chime in, just reminder that was his thought earlier
> this month at LinuxCon.

Well my reasoning was that Open vSwitch isn't a hardware driver
per se, it's much closer to say the bridge module or a tunnel
implementation.

As such we should be very careful before committing to a user-space
interface that we may have to carry forward for years to come.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
