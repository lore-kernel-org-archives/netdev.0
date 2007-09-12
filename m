From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.23-rc6: known regressions with patches
Date: Wed, 12 Sep 2007 19:24:53 +0200
Message-ID: <6bffcb0e0709121024h6b07c4dfl62531c616490082b@mail.gmail.com>
References: <46E81AE2.8030802@googlemail.com>
	 <1189616905.3570.59.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Gabriel C" <nix.or.die@googlemail.com>,
	"Satyam Sharma" <satyam.sharma@gmail.com>,
	"Vitaly Bordug" <vitb@kernel.crashing.org>,
	"Kay Sievers" <kay.sievers@vrfy.org>,
	"Dmitry Torokhov" <dmitry.torokhov@gmail.com>,
	"Greg KH" <gregkh@suse.de>,
	"Anssi Hannula" <anssi.hannula@gmail.com>,
	"=?ISO-8859-1?Q?Toralf_F=F6rster?=" <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org, "Christian Kujau" <lists@nerdbynature.de>,
	jamal <hadi@cyberus.ca>, linux-usb-devel@lists.sourceforge.net,
	sean@mess.org, "Adrian Bunk" <bunk@kernel.org>
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:39219 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763967AbXILRY4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 13:24:56 -0400
Received: by wa-out-1112.google.com with SMTP id v27so310946wah
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 10:24:55 -0700 (PDT)
In-Reply-To: <1189616905.3570.59.camel@shinybook.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/09/2007, David Woodhouse <dwmw2@infradead.org> wrote:
> On Wed, 2007-09-12 at 18:59 +0200, Michal Piotrowski wrote:
> > MTD
> >
> > Subject         : include/linux/mtd/map.h:128:2: error: #error "No =
bus width supported. What's the point?"
> > References      : http://lkml.org/lkml/2007/9/11/151
> > Last known good : ?
> > Submitter       : Toralf F=F6rster <toralf.foerster@gmx.de>
> > Caused-By       : ?
> > Handled-By      : ?
> > Patch           : http://git.infradead.org/?p=3Dmtd-2.6.git;a=3Dcom=
mit;h=3D241651d04d672fb685b2874707016cbbf95931e5
> > Status          : patch available
>
> Didn't you already _drop_ this from your list of regressions once?

Yeah :)

removed.

>
> --
> dwmw2
>
>

Regards,
Michal

--=20
LOG
http://www.stardust.webpages.pl/log/
