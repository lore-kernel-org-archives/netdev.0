From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Fri, 4 Jan 2008 22:24:37 +0100
Message-ID: <64bb37e0801041324j12184660m3c3be34e23dfd957@mail.gmail.com>
References: <64bb37e0801040223q17a76565k3c7667a197403ce5@mail.gmail.com>
	 <20080104133031.GA3329@ff.dom.local>
	 <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	"Tom Tucker" <tom@opengridcomputing.com>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:42267 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbYADVYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 16:24:41 -0500
Received: by py-out-1112.google.com with SMTP id u52so11302641pyb.10
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2008 13:24:41 -0800 (PST)
In-Reply-To: <64bb37e0801040721p57ff3d54wc3de00546d1d2ff1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 4, 2008 4:21 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> On Jan 4, 2008 2:30 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > - above git-nfsd and git-net tests should be probably repeated with
> > -rc6-mm1 git versions: so vanilla rc6 plus both these -mm patches
> > only, and if bug triggers, with one reversed; btw., since in previous
> > message you mentioned that 50 packages could be not enough to trigger
> > this, these 54 above could make too little margin yet.
>
> Yes, I think I really need to redo the git-nfsd-test.
> With IOMMU_DEBUG enabled rc6-mm1worked for 52 packages, only a secound
> run of kde-packages triggered it after only 5 packages.
> I don't know what this bug hates about kdeartwork-wallpaper (triggered
> it this time) or kdeartwork-styles.

49 more (kde-)packages did work too. Still looks like it is only in -mm.

Torsten
