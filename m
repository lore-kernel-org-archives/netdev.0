From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: packet received in a wrong rx-queue?
Date: Wed, 18 May 2011 20:22:07 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D7491A8@MILEXCH2.ds.jdsu.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D748939@MILEXCH2.ds.jdsu.net>
	<4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114@MILEXCH2.ds.jdsu.net>
 <20110518.213225.1546509125052154115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:57200 "HELO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756414Ab1ESD0s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 23:26:48 -0400
In-Reply-To: <20110518.213225.1546509125052154115.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 19, 2011 9:32 AM
> To: Jon Zhou
> Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Subject: Re: packet received in a wrong rx-queue?
> 
> From: Jon Zhou <Jon.Zhou@jdsu.com>
> Date: Wed, 18 May 2011 18:26:07 -0700
> 
> > Anyone can help to check the traffic file?
> 
> I told you yesterday that this behavior is expected.

form the 82599 datasheet, the hash algorithm is consist of src/dst ip, src/dst port,protocol
why it got different hash value with same ip/port pair?
