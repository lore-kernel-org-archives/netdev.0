From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Re: Re: A reliable kernel panic (3.6.2) and system crash when
 visiting a particular website
Date: Sat, 20 Oct 2012 22:19:08 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1210202215350.5948-100000@netrider.rowland.org>
References: <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bp@alien8.de, <pavel@ucw.cz>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <security@kernel.org>,
	<linux-media@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 20 Oct 2012, Artem S. Tashkinov wrote:

> You don't get me - I have *no* VirtualBox (or any proprietary) modules running
> - but I can reproduce this problem using *the same system running under* VirtualBox
> in Windows 7 64.
> 
> It's almost definitely either a USB driver bug or video4linux driver bug:

Does the same thing happen with earlier kernel versions?

What about if you unload snd-usb-audio or ehci-hcd?

Alan Stern
