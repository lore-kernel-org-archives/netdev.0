From: Christof Meerwald <cmeerw@cmeerw.org>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting a
 particular website
Date: Sat, 3 Nov 2012 15:10:49 +0100
Message-ID: <20121103141049.GA24238@edge.cmeerw.net>
References: <2104474742.26357.1350734815286.JavaMail.mail@webmail05>
 <20121020162759.GA12551@liondog.tnic>
 <966148591.30347.1350754909449.JavaMail.mail@webmail08>
 <20121020203227.GC555@elf.ucw.cz>
 <20121020225849.GA8976@liondog.tnic>
 <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1781795634.31179.1350774917965.JavaMail.mail@webmail04>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 20 Oct 2012 23:15:17 +0000 (GMT), Artem S. Tashkinov wrote:
> It's almost definitely either a USB driver bug or video4linux driver bug:
>
> I'm CC'ing linux-media and linux-usb mailing lists, the problem is described here:
> https://lkml.org/lkml/2012/10/20/35
> https://lkml.org/lkml/2012/10/20/148

Not sure if it's related, but I am seeing a kernel freeze with a
usb-audio headset (connected via an external USB hub) on Linux 3.5.0
(Ubuntu 12.10) - see
http://comments.gmane.org/gmane.comp.voip.twinkle/3052 and
http://pastebin.com/aHGe1S1X for a self-contained C test.


Christof

-- 

http://cmeerw.org                              sip:cmeerw at cmeerw.org
mailto:cmeerw at cmeerw.org                   xmpp:cmeerw at cmeerw.org
