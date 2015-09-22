From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] ch9200: Convert to use module_usb_driver
Date: Tue, 22 Sep 2015 08:31:59 +0100
Message-ID: <20150922073159.GA28236@srcf.ucam.org>
References: <1442906989-10664-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:47684 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbIVILl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 04:11:41 -0400
Content-Disposition: inline
In-Reply-To: <1442906989-10664-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 09:29:49AM +0200, Tobias Klauser wrote:
> Converts the ch9200 driver to use the module_usb_driver() macro which
> makes the code smaller and a bit simpler.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Acked-by: Matthew Garrett <mjg59@srcf.ucam.org>

-- 
Matthew Garrett | mjg59@srcf.ucam.org
