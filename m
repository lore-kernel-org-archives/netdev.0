From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v2] tcp: ioctl type SIOCOUTQNSD returns amount of data
 not sent
Date: Fri, 4 Mar 2011 12:39:50 +0000
Message-ID: <20110304123950.2c91ebd9@lxorguk.ukuu.org.uk>
References: <201103041057.53671.arnd@arndb.de>
	<1299234031-13937-1-git-send-email-sledz@dresearch.de>
	<4D70DA8D.9070603@dresearch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Mario Schuknecht <m.schuknecht@dresearch.de>
To: Steffen Sledz <sledz@dresearch.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D70DA8D.9070603@dresearch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > If you plan to add one to Linux then please post the accompanying *tty
> > layer* patches and reasoning, otherwise if it is socket only please stick
> > to the socket ioctl.
> 
> So we should define the new SIOCOUTQNSD in sockios.h only and not similiar to SIOCOUTQ using TIOCOUTQ. Right?

Right

Alan
