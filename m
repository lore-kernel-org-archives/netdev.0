From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH RESEND] 3 ixgb fixes, please pull
Date: Sun, 07 Jan 2007 22:34:13 -0500
Message-ID: <45A1BBB5.8080700@pobox.com>
References: <459FE531.2080604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51859 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030473AbXAHDeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jan 2007 22:34:19 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <459FE531.2080604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> 
> Hi,
> 
> 
> These 3 patches were earlier submitted and ACKed by Jeff Garzik on 
> 12/08, 12/11. They were part of a larger submission that also included 
> e1000 patches. The ixgb patches still need to be merged. The spurious 
> NETIF_F_TSO flags were removed from patch "Fix early TSO completion" as 
> requested.
> 
> These patches apply against netdev-2.6 #upstream-fixes commit
> 81f4e6c190a0fa016fd7eecaf76a5f95d121afc2. Please pull:
> 
> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes

pulled


