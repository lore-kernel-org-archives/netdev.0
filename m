From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: IPv6 enabled Network services
Date: 13 Feb 2003 08:52:38 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030213085238.4096.qmail@webmail18.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "=?iso-8859-1?Q?Marcin_Kami=F1ski?=" <maxiu@maxiu.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Marc
i tried for
telnet> 3ffe::102:304:1234
still i get
3ffe::102:304:1234: unknown host

pls help.

thanx,
San
-------------------------

On Thu, 13 Feb 2003 Marcin Kami=F1ski wrote :
>On Thu, 13 Feb 2003, santosh kumar gowda wrote:
>
> > Hi everybody,
> >
> > I have installed Red Hat Linux 2.4.18-14 on two i386=20
>machines,
> > with
> > kernel compiled for IPv6 support.
> > These machines are connected through a LAN.
> >
> > when i try
> > telnet> 3ffe::102:304:1234/64
> > i get
> > 3ffe::102:304:1234/64 unknown host
> >
> > when doing ftp, same message is given.
> >
> > I would like to know whether i have to configure/modify any
> > scripts,
> > or whether these(ftp, telnet, etc) utilities are IPv6=20
>enabled
> > ???
> >
> > I'm eager to know what is wrong.
> > Please suggest me.
>
>Why do You use prefix-length in addreses? Cut everything after=20
>'/' and '/'
>itself.
>
>--
>- Marcin Kaminski --------------------------------- maxiu -
>--- software developer ------------------- 6net project ---
>----- network administrator -------- Best Group admin -----
>------- Pozna=F1 Supercomputing and Networking Center -------
