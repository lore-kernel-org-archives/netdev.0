From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: Linux v2.6.16-rc6
Date: Sun, 12 Mar 2006 13:04:35 +0100
Message-ID: <6bffcb0e0603120404i2640f64dh@mail.gmail.com>
References: <Pine.LNX.4.64.0603111551330.18022@g5.osdl.org>
	 <6bffcb0e0603111751i1ed30794s@mail.gmail.com>
	 <20060311.183904.71244086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932229AbWCLMEh@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060311.183904.71244086.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 12/03/06, David S. Miller <davem@davemloft.net> wrote:
> From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
> Date: Sun, 12 Mar 2006 02:51:40 +0100
>
> > I have noticed this warnings
> > TCP: Treason uncloaked! Peer 82.113.55.2:11759/50967 shrinks window
> > 148470938:148470943. Repaired.
> > TCP: Treason uncloaked! Peer 82.113.55.2:11759/50967 shrinks window
> > 148470938:148470943. Repaired.
> > TCP: Treason uncloaked! Peer 82.113.55.2:11759/59768 shrinks window
> > 1124211698:1124211703. Repaired.
> > TCP: Treason uncloaked! Peer 82.113.55.2:11759/59768 shrinks window
> > 1124211698:1124211703. Repaired.
> >
> > It maybe problem with ktorrent.
>
> It is a problem with the remote TCP implementation, it is
> illegally advertising a smaller window that it previously
> did.
>

Thanks for explanation.

Regards,
Michal

--
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
