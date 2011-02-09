From: Joe Perches <joe@perches.com>
Subject: Re: [E1000-devel] [PATCH] fixing hw timestamping in igb
Date: Wed, 09 Feb 2011 00:56:41 -0800
Message-ID: <1297241801.17359.169.camel@Joe-Laptop>
References: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se>
	 <1296775407.2698.10.camel@jtkirshe-MOBL1>
	 <331E9D4A-6738-405A-8457-14858D1072DA@halon.se>
	 <DDC57477F5D6F845A0DDCB99D3C4812D0D36DA5C59@orsmsx510.amr.corp.intel.com>
	 <98900162-6C81-4B10-87DD-F43B04DC3F71@halon.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Anders Berggren <anders@halon.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3665 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974Ab1BII4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 03:56:43 -0500
In-Reply-To: <98900162-6C81-4B10-87DD-F43B04DC3F71@halon.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-09 at 09:24 +0100, Anders Berggren wrote:
> Our hardware ping, using Intel 82580 NICs,
> have an accuracy of 8 nanoseconds.

Perhaps you mean 8 nanosecond resolution?
Is documentation available for this claim?


