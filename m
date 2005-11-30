From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: 3C905C-TX
Date: Wed, 30 Nov 2005 15:02:01 +0100
Message-ID: <9a8748490511300602u2cf9f972od6617b8fe777bd9a@mail.gmail.com>
References: <eab8d9e30511300459j695ed942n@mail.gmail.com>
	 <Pine.LNX.4.61.0511300813190.18193@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: =?ISO-8859-1?Q?Daniel_H=F6hnle?= <hoehnle.dan@googlemail.com>,
        Linux kernel <linux-kernel@vger.kernel.org>, andrewm@uow.edu.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0511300813190.18193@chaos.analogic.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 11/30/05, linux-os (Dick Johnson) <linux-os@analogic.com> wrote:
>
> On Wed, 30 Nov 2005, [iso-8859-1] Daniel H=F6hnle wrote:
>
> > Hello i have Suse Linux 9.3 and a 3Com 3C905C-TX Networkcard. But she
> > don't works. Where can I get a Driver??? Or give it a Dokumentation
> > how I can make the Driver??
> >
> > Thanks
> > Daniel H=F6hnle
>
> The 3c59x driver should work for this device. If it's real
> new, you may have to add its ID to the structure at line
> 3365 in 3x59x.c or contact the maintainer.
>
The 3c90x driver available from 3COM themselves is another alternative
: http://support.3com.com/infodeli/tools/nic/linuxdownload.htm

--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
