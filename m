From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: Adding ND to bonding?
Date: Mon, 3 Jun 2013 16:13:17 +0200 (CEST)
Message-ID: <30520718.20.1370268797936.JavaMail.root@zimbra>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.karlsbakk.net ([213.236.233.66]:60993 "EHLO
	zimbra.karlsbakk.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177Ab3FCOT1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 10:19:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by zimbra.karlsbakk.net (Postfix) with ESMTP id 15318F529F
	for <netdev@vger.kernel.org>; Mon,  3 Jun 2013 16:13:23 +0200 (CEST)
Received: from zimbra.karlsbakk.net ([127.0.0.1])
	by localhost (zimbra.karlsbakk.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MFLzjfiH8iFz for <netdev@vger.kernel.org>;
	Mon,  3 Jun 2013 16:13:18 +0200 (CEST)
Received: from zimbra.karlsbakk.net (zimbra.karlsbakk.net [213.236.233.66])
	by zimbra.karlsbakk.net (Postfix) with ESMTP id C12FAF523E
	for <netdev@vger.kernel.org>; Mon,  3 Jun 2013 16:13:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

We're hoping one day we can move to an IPv6-only network (with some gat=
ewaying to IPv4 land), and I wonder if it would be hard to add Neighbor=
 Discovery Protocol to bonding as to allow for bonding on ipv6. I'm not=
 much of a kernel coder, but for what I could see, it looks doable.

Anyone here that has looked into this?

Vennlige hilsener / Best regards

roy
--
Roy Sigurd Karlsbakk
(+47) 98013356
roy@karlsbakk.net
http://blogg.karlsbakk.net/
GPG Public key: http://karlsbakk.net/roysigurdkarlsbakk.pubkey.txt
--
I all pedagogikk er det essensielt at pensum presenteres intelligibelt.=
 Det er et element=C3=A6rt imperativ for alle pedagoger =C3=A5 unng=C3=A5=
 eksessiv anvendelse av idiomer med xenotyp etymologi. I de fleste tilf=
eller eksisterer adekvate og relevante synonymer p=C3=A5 norsk.
