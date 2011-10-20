From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ll_temac: Add support for ethtool
Date: Thu, 20 Oct 2011 17:12:20 -0400 (EDT)
Message-ID: <20111020.171220.590110051530207341.davem@davemloft.net>
References: <1319009725-7869-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, jeffrey.t.kirsher@intel.com,
	grant.likely@secretlab.ca, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ricardo.ribalda@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319009725-7869-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Wed, 19 Oct 2011 09:35:25 +0200

> This patch enables the ethtool interface. The implementation is done
> using the libphy helper functions.

Applied, thanks.

In the future, please put the reviewed-by and signoffs before the "---"
otherwise automated tools will omit it from the final commit message.
