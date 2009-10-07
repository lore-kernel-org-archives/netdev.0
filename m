From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] ethtool: Add reset operation
Date: Wed, 07 Oct 2009 01:28:40 -0700 (PDT)
Message-ID: <20091007.012840.78212772.davem@davemloft.net>
References: <1254426195.2735.16.camel@achroite>
	<20091002104010.GA19862@serverengines.com>
	<1254481219.23350.77.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933684AbZJGI2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:28:45 -0400
In-Reply-To: <1254481219.23350.77.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 02 Oct 2009 12:00:19 +0100

> On Fri, 2009-10-02 at 16:10 +0530, Ajit Khaparde wrote:
> [...]
>> Can you tell the intention behind this copy_to_user?
>> Do you envision drivers sending back some data to the userland - may be
>> sometime in future?
> 
> This allows userland to see which components were actually reset.

Patch applied, thanks.
