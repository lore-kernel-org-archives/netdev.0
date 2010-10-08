From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 8 Oct 2010 19:18:51 +0100
Message-ID: <20101008181851.GA27756@srcf.ucam.org>
References: <20101006151208.GB1571@google.com> <20101008.102803.104075511.davem@davemloft.net> <20101008180310.GA27126@srcf.ucam.org> <20101008.111406.246542521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ellyjones@google.com, netdev@vger.kernel.org, jglasgow@google.com,
	msb@google.com, olofj@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:33442 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754422Ab0JHSTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 14:19:01 -0400
Content-Disposition: inline
In-Reply-To: <20101008.111406.246542521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 11:14:06AM -0700, David Miller wrote:

> I don't think we want a driver in the tree for a device for which the
> firmware isn't even distributable.

Greg didn't seem to think this was a problem when he merged the serial 
driver.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
