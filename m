From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH REPOST] PCI: Disable MSI for MCP55 on P5N32-E SLI
Date: Tue, 18 May 2010 14:33:26 -0700
Message-ID: <20100518143326.72ce1711@virtuousgeek.org>
References: <1273973329.2564.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-pci <linux-pci@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpoproxy1-pub.bluehost.com ([69.89.21.11]:37669 "HELO
	outbound-mail-01.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754234Ab0ERVes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 17:34:48 -0400
In-Reply-To: <1273973329.2564.70.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 May 2010 02:28:49 +0100
Ben Hutchings <ben@decadent.org.uk> wrote:

> As reported in <http://bugs.debian.org/552299>, MSI appears to be
> broken for this on-board device.  We already have a quirk for the
> P5N32-SLI Premium; extend it to cover both variants of the board.
> 
> Reported-by: Romain DEGEZ <romain.degez@smartjog.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Cc: stable@kernel.org
> ---

Applied to linux-next, sorry for missing it earlier.

-- 
Jesse Barnes, Intel Open Source Technology Center
