From: "Yan Seiner" <yan@seiner.com>
Subject: Re: mcp55 forcedeth woes
Date: Tue, 14 Apr 2009 09:47:59 -0700 (PDT)
Message-ID: <acfb5c7f894e2376902adb7d9d5512f6.squirrel@www.datavault.us>
References: <e3e0f4f0ca9fdce35c24b30559d10f31.squirrel@www.datavault.us>
    <200904132100.58056.gene.heskett@verizon.net>
    <49E3EF9F.6090600@seiner.com>
    <200904132224.13716.gene.heskett@verizon.net>
    <49E49F46.8030509@seiner.com> <18916.47906.73896.346385@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Gene Heskett" <gene.heskett@verizon.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	aabdulla@nvidia.com
To: "John Stoffel" <john@stoffel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from flatoutfitness.com ([66.178.130.209]:33507 "EHLO selene"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755992AbZDNQsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 12:48:04 -0400
In-Reply-To: <18916.47906.73896.346385@stoffel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, April 14, 2009 9:34 am, John Stoffel wrote:
>
> I've also got one of these boards, but I seem to recall that 2.6.28
> and higher worked just fine, but when I was chasing another problem
> with complete system crashes when running tcpdump, I found the dead
> port problem as well.

Yeah, this one surfaced after I had a memory stick go bad and lock up the
machine several times.

>
> Thanks for posting your workaround, they'll be a big help.  Esp if I
> put them in early to the system boot process as a quick hack.
>
> The M2N-SLI Deluxe boards are nice though, stable stable stable.  I've
> been very happy with mine.  I wonder if there's a newer BIOS which
> might address some of these issues as well, since it seems to me that
> the BIOS, esp on power up, should be reseting the ports to something
> more sane.

There is a newer bios, 1702, that may address these issues - at least teh
writeup for the 17xx bios for the m2n32 talks about a network lockup fix. 
I haven't tried yet.  These are the most stable boards I've found; one of
mine runs 6 SATA drives locally, 9 via eSATA, 2 dual DVI video cards, and
2 15K scsi drives, all without a hitch.  It never glitches - except for
the d*mn network, this board is a piece of perfection.

-- 
Yan Seiner, PE

Support my bid for the 4J School Board
http://www.seiner.com

