From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware] Mellanox: Add firmware for mlxsw_spectrum
Date: Tue, 30 May 2017 12:22:32 -0700
Message-ID: <20170530192232.GY13400@bombadil.infradead.org>
References: <20170529104228.32947-1-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: idosch@mellanox.com, jiri@mellanox.com, eladr@mellanox.com,
        arkadis@mellanox.com, netdev@vger.kernel.org,
        linux-firmware@kernel.org
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40060 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdE3TWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 15:22:32 -0400
Content-Disposition: inline
In-Reply-To: <20170529104228.32947-1-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 29, 2017 at 01:42:28PM +0300, Yotam Gigi wrote:
> Add first firmware for the Mellanox Spectrum switch, as a followup to the
> recently added commit:
> 6b7421992b8d ("mlxsw: spectrum: Validate firmware revision on init")
> 
> The version of the firmware release is 13.1420.122
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> ---
>  mlxsw_spectrum-13.1420.122.mfa2 | Bin 0 -> 860424 bytes
>  1 file changed, 0 insertions(+), 0 deletions(-)
>  create mode 100644 mlxsw_spectrum-13.1420.122.mfa2
> 
> diff --git a/mlxsw_spectrum-13.1420.122.mfa2 b/mlxsw_spectrum-13.1420.122.mfa2
> new file mode 100644

Can we please put this in a subdirectory if we're going to be adding
more versions of this in the future?

--Kyle
