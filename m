From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware v2] Mellanox: Add firmware for
 mlxsw_spectrum
Date: Thu, 1 Jun 2017 10:18:50 -0700
Message-ID: <20170601171850.GA13400@bombadil.infradead.org>
References: <20170601062810.17813-1-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: idosch@mellanox.com, jiri@mellanox.com, eladr@mellanox.com,
        arkadis@mellanox.com, netdev@vger.kernel.org,
        linux-firmware@kernel.org
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:47239 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbdFARSv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:18:51 -0400
Content-Disposition: inline
In-Reply-To: <20170601062810.17813-1-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 09:28:10AM +0300, Yotam Gigi wrote:
> Add first firmware for the Mellanox Spectrum switch, as a followup to the
> recently added commit:
> 6b7421992b8d ("mlxsw: spectrum: Validate firmware revision on init")
> 
> The version of the firmware release is 13.1420.122
> 

applied, thanks Yotam.

--kyle

> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> ---
>  mellanox/mlxsw_spectrum-13.1420.122.mfa2 | Bin 0 -> 860424 bytes
>  1 file changed, 0 insertions(+), 0 deletions(-)
>  create mode 100644 mellanox/mlxsw_spectrum-13.1420.122.mfa2
> 
