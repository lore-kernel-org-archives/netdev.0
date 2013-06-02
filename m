From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 3/3] Kconfig: remove dangling references to the deleted file
Date: Sun, 02 Jun 2013 12:09:40 +0200
Message-ID: <df6f5786-e49c-4564-a9de-35825048f0a7@email.android.com>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com> <1370139797-8912-3-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53274 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752868Ab3FBKJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jun 2013 06:09:44 -0400
In-Reply-To: <1370139797-8912-3-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Sacren <sakiwit@gmail.com> wrote:

>diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>index 8603ca8..37cf1a6 100644
>--- a/net/ipv4/Kconfig
>+++ b/net/ipv4/Kconfig
>@@ -9,10 +9,7 @@ config IP_MULTICAST
> 	  intend to participate in the MBONE, a high bandwidth network on to=
p
> 	  of the Internet which carries audio and video broadcasts. More
> 	  information about the MBONE is on the WWW at
>-	  <http://www.savetz.com/mbone/>. Information about the multicast
>-	  capabilities of the various network cards is contained in
>-	  <file:Documentation/networking/multicast.txt>. For most people,
>it's
>-	  safe to say N.
>+	  <http://www.savetz.com/mbone/>. For most people, it's safe to say
>N.

This url results in a 404 error, so you might as well delete it while c=
leaning up this.

Bj=C3=B8rn=20
