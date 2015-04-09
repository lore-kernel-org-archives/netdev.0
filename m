From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Thu, 09 Apr 2015 10:36:23 +0200
Message-ID: <55263A07.6040508@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m2h9t7bubh.wl@wide.ad.jp>	<5514560A.7040707@nod.at>	<m28uejaqyn.wl@wide.ad.jp>	<55152137.20405@nod.at>	<m2sicnalnh.wl@sfc.wide.ad.jp>	<5518F030.4040003@nod.at> <m2y4md7gmb.wl@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
	rusty@rustcorp.com.au, mathieu.lacage@gmail.com
To: Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m2y4md7gmb.wl@wide.ad.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 31.03.2015 um 09:47 schrieb Hajime Tazaki:
> right now arch/lib/Makefile isn't fully on the Kbuild
> system: build file dependency is not tracked at all.
> 
> while I should learn more about Kbuild, I'd be happy if you
> would suggest how the Makefile should be.

You definitely have to use Kbuild.
Please bite the bullet and dig into it. Maybe we
need also new functions in Kbuild to support a library mode.
Who knows? ;)

Thanks,
//richard
