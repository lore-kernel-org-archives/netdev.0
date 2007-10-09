From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 09:00:10 -0400
Message-ID: <470B7B5A.7050307@garzik.org>
References: <20071009.040255.71088090.davem@davemloft.net> <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com> <20071009.042441.30182968.davem@davemloft.net> <470B77A9.600@garzik.org> <20071009125513.GA19650@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	jagana@us.ibm.com, johnpol@2ka.mipt.ru, kaber@trash.net,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60399 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523AbXJINAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 09:00:37 -0400
In-Reply-To: <20071009125513.GA19650@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Oct 09, 2007 at 08:44:25AM -0400, Jeff Garzik wrote:
>> David Miller wrote:
>>> I can just threaten to do them all and that should get the driver
>>> maintainers going :-)
>> What, like this?  :)
> 
> Awsome :)

Note my patch is just to get the maintainers going.  :)  I'm not going 
to commit that, since I don't have any way to test any of the drivers I 
touched (but I wouldn't scream if it appeared in net-2.6.24 either)

	Jeff


