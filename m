From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next 3/3] Kconfig: remove dangling references to the
 deleted file
Date: Sun, 2 Jun 2013 11:28:57 -0600
Message-ID: <20130602172857.GE26681@mail.gmail.com>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
 <1370139797-8912-3-git-send-email-sakiwit@gmail.com>
 <df6f5786-e49c-4564-a9de-35825048f0a7@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34478 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754664Ab3FBRa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 13:30:27 -0400
Received: by mail-ie0-f170.google.com with SMTP id e14so8429018iej.15
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 10:30:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <df6f5786-e49c-4564-a9de-35825048f0a7@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sun, 02 Jun 2013 12:09:40 +0200
>
> Jean Sacren <sakiwit@gmail.com> wrote:
>=20
> >diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> >index 8603ca8..37cf1a6 100644
> >--- a/net/ipv4/Kconfig
> >+++ b/net/ipv4/Kconfig
> >@@ -9,10 +9,7 @@ config IP_MULTICAST
> > 	  intend to participate in the MBONE, a high bandwidth network on =
top
> > 	  of the Internet which carries audio and video broadcasts. More
> > 	  information about the MBONE is on the WWW at
> >-	  <http://www.savetz.com/mbone/>. Information about the multicast
> >-	  capabilities of the various network cards is contained in
> >-	  <file:Documentation/networking/multicast.txt>. For most people,
> >it's
> >-	  safe to say N.
> >+	  <http://www.savetz.com/mbone/>. For most people, it's safe to sa=
y
> >N.
>=20
> This url results in a 404 error, so you might as well delete it while=
 cleaning up this.

I did check this URL before I submitted the patch and it worked:

	http://www.savetz.com/mbone/

I just checked again and it still works. Can you check one more time fo=
r
me, please?

--=20
Jean Sacren
