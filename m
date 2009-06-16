From: David Miller <davem@davemloft.net>
Subject: Re: "sky2: set VPD size" triggers card recognition failure
Date: Tue, 16 Jun 2009 02:26:20 -0700 (PDT)
Message-ID: <20090616.022620.61989153.davem@davemloft.net>
References: <20090611100347.7c4160a4@nehalam>
	<20090612115120.GA13960@shadowen.org>
	<20090615101753.GB13761@shadowen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750961AbZFPJ0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:26:17 -0400
In-Reply-To: <20090615101753.GB13761@shadowen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Whitcroft <apw@canonical.com>
Date: Mon, 15 Jun 2009 11:17:53 +0100

> On Fri, Jun 12, 2009 at 12:51:20PM +0100, Andy Whitcroft wrote:
>> On Thu, Jun 11, 2009 at 10:03:47AM -0700, Stephen Hemminger wrote:
>> 
>> > Some of the chip version have different registers, and some hardware vendors build
>> > boards without VPD.  Does this help:
>> 
>> Thanks for the patch.  I have built some kernels and pushed them out
>> for testing.  Will let you know what comes of it!
> 
> Ok, that tests out good as well.
> 
> Tested-by: Andy Whitcroft <apw@canonical.com>

Applied, thanks everyone.
