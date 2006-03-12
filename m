From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: Linux v2.6.16-rc6
Date: Sun, 12 Mar 2006 02:51:40 +0100
Message-ID: <6bffcb0e0603111751i1ed30794s@mail.gmail.com>
References: <Pine.LNX.4.64.0603111551330.18022@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751454AbWCLBvm@vger.kernel.org>
To: "Linus Torvalds" <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0603111551330.18022@g5.osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 12/03/06, Linus Torvalds <torvalds@osdl.org> wrote:
>
> Ok, we're getting closer, although the 2.6.16 release certainly seems to
> drag out more than it should have.
>

I have noticed this warnings
TCP: Treason uncloaked! Peer 82.113.55.2:11759/50967 shrinks window
148470938:148470943. Repaired.
TCP: Treason uncloaked! Peer 82.113.55.2:11759/50967 shrinks window
148470938:148470943. Repaired.
TCP: Treason uncloaked! Peer 82.113.55.2:11759/59768 shrinks window
1124211698:1124211703. Repaired.
TCP: Treason uncloaked! Peer 82.113.55.2:11759/59768 shrinks window
1124211698:1124211703. Repaired.

It maybe problem with ktorrent.

Here is config http://www.stardust.webpages.pl/files/linux/2.6.16-rc6/config
Here is dmesg http://www.stardust.webpages.pl/files/linux/2.6.16-rc6/dmesg

Regards,
Michal

--
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)
