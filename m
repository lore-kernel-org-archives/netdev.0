From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v4] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Fri, 21 Mar 2014 11:19:35 +0100
Message-ID: <CAMuHMdWt+z08vK0TcQ9VZN0QiybqVK568RR-0NPCoT6cmf6LKA@mail.gmail.com>
References: <1395396888-24306-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@lists.codethink.co.uk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1395396888-24306-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On Fri, Mar 21, 2014 at 11:14 AM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> Note, Laurent this should probably be applied before your
> current series as it may require changes to the exit sequence.

Laurent's series is already in netdev-next, so I think you'll have to
build on top of that.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
