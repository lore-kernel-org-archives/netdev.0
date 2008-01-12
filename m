From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 12 Jan 2008 18:57:24 +1100
Message-ID: <1200124644.6896.99.camel@pasglop>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	 <20080111174822.GB17240@gate.ebshome.net>
	 <1200089457.6896.65.camel@pasglop>  <200801120826.53091.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eugene Surovegin <ebs@ebshome.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58304 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758501AbYALH5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 02:57:50 -0500
In-Reply-To: <200801120826.53091.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-01-12 at 08:26 +0100, Stefan Roese wrote:
> 
> We shouldn't make it too complicated. We can always select different
> settings 
> in the defconfig file. My thinking here is to better wast a little
> memory 
> with a potential performance improvement. Just me 0.02$

If it gets really critical, then we can move those settings to the
device-tree.

Ben.


