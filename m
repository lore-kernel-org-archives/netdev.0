From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: fix queue limits in multiple qdiscs
Date: 17 Nov 2003 10:01:24 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069081284.1024.23.camel@jzny.localdomain>
References: <3FB39A2D.5020000@trash.net>
	 <1069076955.1076.23.camel@jzny.localdomain>  <3FB8DF9F.7030509@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB8DF9F.7030509@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Like i said it is valid - but i wouldnt go out of my way to fix it
(especially when 2.6 is frozen).

cheers,
jamal

On Mon, 2003-11-17 at 09:47, Patrick McHardy wrote:
> I don't have strong feelings about this, I just kept wondering why tc
> displayes "pfifo limit 10 backlog 11".
> 
> Best regards,
> Patrick
> 
> jamal wrote:
> 
> >valid but Too cosmetic, IMO; (who cares when you are off by a few
> >bytes?)
> >
> >cheers,
> >jamal
> >
> 
> 
> 
