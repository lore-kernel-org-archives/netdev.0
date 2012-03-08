From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 0/7] powerpc: remove the legacy iSeries platform specific
 drivers
Date: Thu, 08 Mar 2012 11:37:18 +0100
Message-ID: <4F588BDE.3080503@kernel.dk>
References: <20120308152853.b5010336abbb8f90e8a2500c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	ppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	netdev@vger.kernel.org, Alan Cox <alan@linux.intel.com>,
	Brian King <brking@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120308152853.b5010336abbb8f90e8a2500c@canb.auug.org.au>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/08/2012 05:28 AM, Stephen Rothwell wrote:
> It would probably be easiest if all these patches were merged via the
> powerpc tree to eliminate any dependencies between them.  Their impact on
> generic code is very small.

Go ahead, no point in doing otherwise.

-- 
Jens Axboe

