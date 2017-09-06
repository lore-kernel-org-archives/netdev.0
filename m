From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 6/10] ixgbe: Use ARRAY_SIZE macro
Date: Wed, 06 Sep 2017 08:19:18 -0700
Message-ID: <1504711158.7546.1.camel@perches.com>
References: <20170905.115044.551456011251065741.davem@davemloft.net>
         <20170905194419.pdwrkqdad6tbq7hs@olymp>
         <1504641678.28899.12.camel@perches.com>
         <20170905.142205.14687531780483930.davem@davemloft.net>
         <20170906090817.f7qir5okeeajfcsc@olymp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Meyer <thomas@m3y3r.de>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906090817.f7qir5okeeajfcsc@olymp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-06 at 11:08 +0200, Thomas Meyer wrote:
> On Tue, Sep 05, 2017 at 02:22:05PM -0700, David Miller wrote:
> > nothing prevented you from CC:'ing the maintainer,
> > Jeff Kirscher.
[]
> That's the other condition in my script. I only send to the role
> "maintainer" from the output of get_maintainer.pl. But Mr Jeff
> Kirscher is only listed as supporter...

Supporter means he gets paid to look after that
subsystem so he is something other than a volunteer.

from MAINTAINERS:
	S: Status, one of the following:
	   Supported:	Someone is actually paid to look after this.
	   Maintained:	Someone actually looks after it.
	   Odd Fixes:	It has a maintainer but they don't have time to do
			much other than throw the odd patch in. See below..
	   Orphan:	No current maintainer [but maybe you could take the
			role as you write your new code].
	   Obsolete:	Old code. Something tagged obsolete generally means
			it has been replaced by a better system and you
			should be using that.
