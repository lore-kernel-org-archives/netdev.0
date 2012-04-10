From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4/5] staging: octeon_ethernet: Convert to use device tree.
Date: Tue, 10 Apr 2012 09:43:16 -0700
Message-ID: <20120410164316.GA15131@kroah.com>
References: <1332808075-8333-1-git-send-email-ddaney.cavm@gmail.com>
 <1332808075-8333-5-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>,
	netdev@vger.kernel.org
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332808075-8333-5-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 26, 2012 at 05:27:54PM -0700, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
> 
> Get MAC address and PHY connection from the device tree.  The driver
> is converted to a platform driver.
> 
> Cc: netdev@vger.kernel.org
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
> 
> Should probably go via Ralf's linux-mips.org tree.

That's fine with me:
	Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
