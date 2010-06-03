From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] phylib: Add support for the LXT973 phy.
Date: Thu, 3 Jun 2010 13:28:34 +0200
Message-ID: <20100603112834.GA2724@riccoc20.at.omicron.at>
References: <20100602125527.GA20396@riccoc20.at.omicron.at>
 <20100602.065017.139108801.davem@davemloft.net>
 <20100602150851.GA22591@riccoc20.at.omicron.at>
 <20100602.081512.256851057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:10762 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab0FCL2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 07:28:08 -0400
Received: by fg-out-1718.google.com with SMTP id d23so391030fga.1
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 04:28:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100602.081512.256851057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 02, 2010 at 08:15:12AM -0700, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Wed, 2 Jun 2010 17:08:51 +0200
> 
> > Well, is it okay to just use the first patch?
> 
> Wasn't there another change you were asked to make that got included
> in the v2 patch?

No, I don't think so. He did ask whether the erratum has been fixed.
I will implement the 'port' field that he has suggested.

Richard
