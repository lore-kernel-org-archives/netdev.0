From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] e1000, errata 2{3,
	4} - possible EEH or memory corruption when DMA crosses a 64k
	boundary
Date: Tue, 1 Feb 2005 13:33:59 -0600
Message-ID: <200502011333.59262.jdmason@us.ibm.com>
References: <20050201192735.GB7433@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
	Ganesh Venkatesan <ganesh.venkatesan@intel.com>,
	linuxppc64-dev@ozlabs.org
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20050201192735.GB7433@suse.de>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tuesday 01 February 2005 01:27 pm, Olaf Hering wrote:
> 
> We have this patch in SLES9 SP1.
> I asked google about 'fix for errata 23, cant cross 64kB boundary', and
> it shhows such a patch is also part of RH 2.6.9.
> It still applies to current Linus tree.
> Can you check wether this is still required for the current driver?

This patch is still lacking from the latest e1000 driver.  Intel has the patch in their queue, so it will be needed until they release their next version of the e1000 driver.
