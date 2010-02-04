From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 1/2] qlge: removing unreachable block of code
Date: Thu, 4 Feb 2010 15:11:30 -0800
Message-ID: <20100204231130.GD9938@linux-ox1b.qlogic.org>
References: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:32954 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758082Ab0BDXSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 18:18:25 -0500
Content-Disposition: inline
In-Reply-To: <48284d15bf68cb154cf3948f3fd0b8ea11981ff3.1265314112.git.root@sanx1002.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2010 at 12:11:18PM -0800, leitao@linux.vnet.ibm.com wrote:
> Currently the qlge_change_mtu() is never called if the new_mtu is
> equal current MTU, due this condition on dev_set_mtu():

Both look good.  Thanks


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
