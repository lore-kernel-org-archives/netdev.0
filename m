From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Wed, 06 Jan 2016 16:02:29 -0800
Message-ID: <1452124949.24575.65.camel@perches.com>
References: <1452121966.24575.52.camel@perches.com>
	 <87vb76b87m.fsf@nemi.mork.no> <1452123144.24575.57.camel@perches.com>
	 <20160106.190107.1969093816791419629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0203.hostedemail.com ([216.40.44.203]:37079 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753136AbcAGACc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 19:02:32 -0500
In-Reply-To: <20160106.190107.1969093816791419629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 19:01 -0500, David Miller wrote:
> The caller checks for NULL, and this is the default implementation
> doing precisely what it is meant to do.

Yeah, I noticed that later. Nevermind...

cheers, Joe
