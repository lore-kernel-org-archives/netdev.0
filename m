From: =?UTF-8?B?QXVyw6lsaWVu?= <footplus@gmail.com>
Subject: Optics (SFP) monitoring on ixgbe and igbe
Date: Wed, 7 Nov 2012 13:27:05 +0100
Message-ID: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
Reply-To: footplus@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:50250 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab2KGM10 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 07:27:26 -0500
Received: by mail-qc0-f174.google.com with SMTP id o22so971839qcr.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 04:27:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm looking to propose a patch for optics monitoring on igbe and ixgbe
cards which support SFP and SFP+. I have one of each card. While
searching for previous work done by others on this domain, i found the
following:

https://github.com/jelaas/bifrost-build-x86_64/tree/master/all/kernel-x=
86_64-3.3.0-rc2-1
(the DOM-* files)

I did not yet test this patch (i'll do in a few days), but just by
looking at the patches, do you think this could get incorporated in
the current state, provided some administrative work is done, or would
it require more architectural rework / documentation / other ?

Could you point me to the next steps required for the functionality to
be merged in a future mainline kernel/ethtool ? Is there a better
place than netdev@ to discuss this matter ?

Thanks,
--=20
Aur=C3=A9lien Guillaume
