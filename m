From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 09:49:40 -0500
Message-ID: <d120d50005031006492511c48@mail.gmail.com>
References: <B8561865DB141248943E2376D0E85215FFE3D6@DHOST001-17.DEX001.intermedia.net>
Reply-To: dtor_core@ameritech.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>, hadi@cyberus.ca,
        Henrik Nordstrom <hno@marasystems.com>, Martin Mares <mj@ucw.cz>,
        Zdenek Radouch <zdenek@rcn.com>, Eran Mann <emann@mrv.com>,
        Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Steve Iribarne <steve.iribarne@dilithiumnetworks.com>
In-Reply-To: <B8561865DB141248943E2376D0E85215FFE3D6@DHOST001-17.DEX001.intermedia.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 06:35:43 -0800, Steve Iribarne
<steve.iribarne@dilithiumnetworks.com> wrote:
> -> You say that a client will not allow you to use net 10.
> -> OK, but, the same client would not allow you to use 127/8 because
> they
> -> use
> -> it!
> -> What I'm saying is that 10.0.0.0/8 and 127.0.0.0/8 are the same. The
> -> customer can use them.
> -> You assume that the client will not use 127/8. Why? This is wrong.
> -> You can use it, the client can use it.
> ->
> 
> No.  If the client uses 127/8 on a linux box, it is just a loopback and
> will never go out on the wire and the applications (i.e. telnet, ftp,
> ping, whatever) will just loopback.
> 

This assumes that the client did not apply the same hack you did.

-- 
Dmitry
