From: "Roberts, Lee A." <lee.roberts@hp.com>
Subject: RE: [PATCH 1/3] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Thu, 21 Feb 2013 16:43:52 +0000
Message-ID: <D64EC45690EF85409BA6C4730E0162244310DEE0@G4W3231.americas.hpqcorp.net>
References: <1361374860.3450.1.camel@laptop.lroberts>
	<D64EC45690EF85409BA6C4730E0162244310ABA1@G4W3231.americas.hpqcorp.net>
 <20130220.125301.1295321158433252629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130220.125301.1295321158433252629.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 20, 2013 10:53 AM
> To: Roberts, Lee A.
> Cc: linux-sctp@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 1/3] sctp: fix association hangs due to reassembly/ordering logic
> 
> 
> Your email client has corrupted every one of your patches, splitting up
> new lines as well as making other alterations, making them useless for
> us.
> 
> Please read Documentation/email-clients.txt to learn how to fix this
> problem, and only resubmit your patches when you can successfully
> email a patch to yourself and cleanly apply the patch you receive
> in that email as-is.
> 
> Thanks.

I have addressed the e-mail client issue and have successfully mailed the
patches to myself and applied them.  I will be sending updated version shortly.

I have incorporated changes and recommendations from Vlad Yasevich into
the updated patches.

                                 - Lee Roberts
