From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Fri, 4 Mar 2011 23:41:30 +0100
Message-ID: <20110304224130.GA13718@electric-eye.fr.zoreil.com>
References: <4D4FE100.5090808@gmail.com> <loom.20110214T141934-88@post.gmane.org> <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com> <loom.20110226T011347-702@post.gmane.org> <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com> <loom.20110226T120245-774@post.gmane.org> <AANLkTimmbG3_GjYhoO7F46hOcRM3Fq_mNifk2PpLstPa@mail.gmail.com> <20110301101609.GA13261@electric-eye.fr.zoreil.com> <20110301215252.GA13336@electric-eye.fr.zoreil.com> <loom.20110304T202925-568@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: chriss <mail_to_chriss@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57282 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932569Ab1CDWp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 17:45:56 -0500
Content-Disposition: inline
In-Reply-To: <loom.20110304T202925-568@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

chriss <mail_to_chriss@gmx.net> :
[...]
> I hope i'm doing it right. i checked out the
> 'git://git.kernel.org/pub/scm/linux/kernel/git/sfr/linux-next.git'
> 
> and will try to apply the patch you provided. please correct me if i'm wrong.
> I will report back.

I have tested it against davem's -next somewhere along -rc5 but it should be
fine as well.

-- 
Ueimor
