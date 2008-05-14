From: "Shirish Pargaonkar" <shirishpargaonkar@gmail.com>
Subject: Re: autotuning of send buffer size of a socket
Date: Wed, 14 May 2008 13:37:38 -0500
Message-ID: <4a4634330805141137y25c54b1t19992e777c00d8b5@mail.gmail.com>
References: <4a4634330805121200m739e67bdife66c3ad81af1ceb@mail.gmail.com>
	 <1210639647.2753.10.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805130654n1aafbf10pa73da07e792f7b@mail.gmail.com>
	 <1210722503.11436.9.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805140722x3494626bpc78dd92831d384a@mail.gmail.com>
	 <4a4634330805141111s585fd928n824e20fc83a74819@mail.gmail.com>
	 <1210789577.6956.9.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Sridhar Samudrala" <sri@us.ibm.com>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: "Jeremy Jackson" <jerj@coplanar.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1210789577.6956.9.camel@ragnarok>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/14/08, Jeremy Jackson <jerj@coplanar.net> wrote:
> Sorry if this has been covered already, but doesn't Samba set the write
> buffer size, thereby disabling autotuning?
>
> --
> Jeremy Jackson
> Coplanar Networks
> (519)489-4903
> http://www.coplanar.net
> jerj@coplanar.net
>
>

Jeremy,

I would like auto-tuning to happen on the machine running cifs/samba client.
That is where the errors are logged.  The auto-tune happens on the client side,
just not good enough to ward off the delays (and subsequent errors logged
by cifs client and reconnects initated by cifs client to samba server
running on other
machine.) for reasons.

Regards,

Shirish
