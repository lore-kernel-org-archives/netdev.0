From: jamal <hadi@cyberus.ca>
Subject: Re: Asynchronous crypto layer.
Date: 29 Oct 2004 11:11:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1099062674.1026.24.camel@jzny.localdomain>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru> <41824D9A.3070407@logix.cz>
	 <20041029183606.0b1a0538@zanzibar.2ka.mipt.ru>
	 <Pine.LNX.4.61.0410291636020.25667@maxipes.logix.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <Pine.LNX.4.61.0410291636020.25667@maxipes.logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-29 at 10:53, Michal Ludvig wrote:
> On Fri, 29 Oct 2004, Evgeniy Polyakov wrote:
.
> > 
> > If you compile this sources then you will still have old sync behaviour, 
> > IPsec and any other old-style application should be rewritten(like 
> > attached consumer.c) to use new asynchronous crypto layer features.
> 
> This could be a bit of problem, because AFAIK the IPsec code doesn't allow 
> sleeping while processing the packet. It will likely need a bigger 
> rewrite.
> 

I dont think its a big rewrite.  

cheers,
jamal
