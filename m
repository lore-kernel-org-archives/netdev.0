From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 01 Feb 2011 23:33:49 -0800
Message-ID: <1296632029.26937.871.camel@localhost.localdomain>
References: <1296594585.26937.817.camel@localhost.localdomain>
	 <20110201212411.GD30770@redhat.com>
	 <1296595955.26937.822.camel@localhost.localdomain>
	 <20110201214211.GB31105@redhat.com>
	 <1296597185.26937.829.camel@localhost.localdomain>
	 <20110201215603.GA31348@redhat.com>
	 <1296601197.26937.833.camel@localhost.localdomain>
	 <20110202044002.GB3818@redhat.com>
	 <1296626748.26937.852.camel@localhost.localdomain>
	 <1296627549.26937.856.camel@localhost.localdomain>
	 <20110202062950.GD3818@redhat.com>
	 <1296630891.26937.870.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41681 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab1BBHd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 02:33:57 -0500
In-Reply-To: <1296630891.26937.870.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-01 at 23:14 -0800, Shirley Ma wrote:
> w/i guest change, I played around the parameters,for example: I could
> get 3.7Gb/s with 42% CPU BW increasing from 2.5Gb/s for 1K message
> size,
> w/i dropping packet, I was able to get up to 6.2Gb/s with similar CPU
> usage. 

I meant w/o guest change, only vhost changes. Sorry about that.

Shirley

