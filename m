From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.24] pcnet32:  use NET_IP_ALIGN instead of 2
Date: Mon, 11 Feb 2008 10:30:17 -0500
Message-ID: <47B06A09.60204@pobox.com>
References: <1202484746.10535.7.camel@new-host.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52400 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032AbYBKPaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:30:19 -0500
In-Reply-To: <1202484746.10535.7.camel@new-host.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don Fry wrote:
> Change hard coded 2 to NET_IP_ALIGN.  Added new #define with comments.
> Tested amd_64
> 
> Signed-off-by:  Don Fry <pcnet32@verizon.net>

applied both


