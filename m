From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Sat, 5 Mar 2011 10:53:50 +0000 (UTC)
Message-ID: <loom.20110305T115102-411@post.gmane.org>
References: <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com> <loom.20110226T011347-702@post.gmane.org> <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com> <loom.20110226T120245-774@post.gmane.org> <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com> <20110301101609.GA13261@electric-eye.fr.zoreil.com> <20110301215252.GA13336@electric-eye.fr.zoreil.com> <loom.20110304T202925-568@post.gmane.org> <20110304224130.GA13718@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:48490 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab1CEKyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 05:54:05 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Pvp7Z-0002ie-3G
	for netdev@vger.kernel.org; Sat, 05 Mar 2011 11:54:01 +0100
Received: from HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de ([109.193.65.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 11:54:01 +0100
Received: from mail_to_chriss by HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 11:54:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu <at> fr.zoreil.com> writes:

> 
> chriss <mail_to_chriss <at> gmx.net> :
> [...]
> > I hope i'm doing it right. i checked out the
> > 'git://git.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git'
> > 
> > and will try to apply the patch you provided. please correct me if i'm wrong.
> > I will report back.
> 
> I have tested it against davem's -next somewhere along -rc5 but it should be
> fine as well.
> 

My hat gows of to you kindly sir! Everything works as expected. im looking
forward to see this patch in the stable releases.

thank you very much
//chriss

