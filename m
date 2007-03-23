From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] SAA9730: Fix large pile of warnings
Date: Fri, 23 Mar 2007 01:50:19 -0400
Message-ID: <46036A9B.3020202@garzik.org>
References: <20070320124009.GA6927@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60456 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753179AbXCWFuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:50:21 -0400
In-Reply-To: <20070320124009.GA6927@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> The SAA9730 driver doesn't quite grok what the difference between an ioport
> and memory mapped I/O is.  It just happened to work on the one Linux
> system the SAA9730 happens to spend it's misserable existence on.

applied


