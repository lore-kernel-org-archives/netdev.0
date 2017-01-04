From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] dpaa_eth: a couple of fixes
Date: Wed, 04 Jan 2017 13:45:28 -0500 (EST)
Message-ID: <20170104.134528.1077940126567605741.davem@davemloft.net>
References: <1483528890-8621-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483528890-8621-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Wed, 4 Jan 2017 13:21:28 +0200

> Add cleanup on PHY initialization failure path, avoid using
> uninitialized memory at CGR init.

Series applied, thanks.
