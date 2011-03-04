From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Fri, 4 Mar 2011 19:32:09 +0000 (UTC)
Message-ID: <loom.20110304T202925-568@post.gmane.org>
References: <AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com> <loom.20110206T203347-475@post.gmane.org> <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com> <loom.20110226T011347-702@post.gmane.org> <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com> <loom.20110226T120245-774@post.gmane.org> <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com> <20110301101609.GA13261@electric-eye.fr.zoreil.com> <20110301215252.GA13336@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:40250 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759792Ab1CDTcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 14:32:22 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Pvajc-0003p2-I1
	for netdev@vger.kernel.org; Fri, 04 Mar 2011 20:32:20 +0100
Received: from HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de ([109.193.65.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 20:32:20 +0100
Received: from mail_to_chriss by HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 20:32:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu <at> fr.zoreil.com> writes:

> 
> Chriss, can you give it a try against current -rc / -git and see if it makes
> a difference ?
> 

I hope i'm doing it right. i checked out the
'git://git.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git'

and will try to apply the patch you provided. please correct me if i'm wrong.
I will report back.

regards//chriss

