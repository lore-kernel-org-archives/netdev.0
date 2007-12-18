From: David Chinner <dgc@sgi.com>
Subject: Re: [0/4] DST: Distributed storage.
Date: Tue, 18 Dec 2007 12:00:04 +1100
Message-ID: <20071218010003.GE4396912@sgi.com>
References: <20071214133747.GC31971@2ka.mipt.ru> <11979038181687@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:38206 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750743AbXLRBAN (ORCPT
	<rfc822;@relay.sgi.com:netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:00:13 -0500
Content-Disposition: inline
In-Reply-To: <11979038181687@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 06:03:38PM +0300, Evgeniy Polyakov wrote:
> DST passed all FS tests in LTP with XFS (modulo MAX_LOCK_DEPTH too low bug:
> [ 8398.605691] BUG: MAX_LOCK_DEPTH too low!
> [ 8398.609641] turning off the locking correctness validator.

Evgeniy, can you please start reporting these XFS problems you are
coming across to the XFS list (xfs@oss.sgi.com)? They may be
real issues that we need to address and we should not be hearing
about them for the first time in the release notes for a block
device project....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group
