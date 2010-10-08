From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 8 Oct 2010 20:05:34 +0100
Message-ID: <20101008190534.GA29052@srcf.ucam.org>
References: <20101008180310.GA27126@srcf.ucam.org> <20101008.111406.246542521.davem@davemloft.net> <20101008181851.GA27756@srcf.ucam.org> <20101008.115050.28825457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ellyjones@google.com, netdev@vger.kernel.org, jglasgow@google.com,
	msb@google.com, olofj@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:40964 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352Ab0JHTFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 15:05:43 -0400
Content-Disposition: inline
In-Reply-To: <20101008.115050.28825457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 11:50:50AM -0700, David Miller wrote:

> I don't see how any distribution can properly support this device
> if it cannot work without non-distributable firmware.

Individual vendors may negotiate redistribution agreements with 
Qualcomm. We've carried drivers without redistributable firmware in the 
past (b43 had none for some time), so I don't see that we have any clear 
and established position on this.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
