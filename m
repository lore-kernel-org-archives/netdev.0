From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/3] chelsio: NAPI speed improvement
Date: Thu, 18 Jan 2007 22:05:38 -0500
Message-ID: <45B03582.5040007@pobox.com>
References: <20061215190716.956791000@osdl.org> <4591912E.60402@pobox.com> <20070108112426.2a5e43fa@dxpl.pdx.osdl.net> <20070108112630.6c081687@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47682 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964783AbXASDFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:05:41 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070108112630.6c081687@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Speedup and cleanup the receive processing by eliminating the
> mmio read and a lock round trip.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied

