From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: [PATCH] kill ancient compat cruft from acenic
Date: 21 Jan 2004 03:36:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <yq065f566m6.fsf@wildopensource.com>
References: <20040120141717.GA7549@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040120141717.GA7549@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Christoph" == Christoph Hellwig <hch@lst.de> writes:

Christoph> This kills all the cruft needed for supporting anything
Christoph> other than halfway recent 2.4 and 2.6 kernels.  Should make
Christoph> converting to the pci hotplug APIs much easier.

Looks pretty decent, are you sure the MOD_INC_USE_COUNT isn't needed
for 2.4.18+ ? (no I haven't checked).

Other than that I am fine with the patch.

Cheers,
Jes
