From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: IPv6 bonding support?
Date: Wed, 14 Nov 2012 09:26:37 +0100 (CET)
Message-ID: <5791379.6.1352881597330.JavaMail.root@zimbra>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.karlsbakk.net ([213.236.233.66]:53486 "EHLO
	zimbra.karlsbakk.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab2KNIe0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 03:34:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by zimbra.karlsbakk.net (Postfix) with ESMTP id 667DCF5363
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 09:26:38 +0100 (CET)
Received: from zimbra.karlsbakk.net ([127.0.0.1])
	by localhost (zimbra.karlsbakk.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZoR2jB-kgt1A for <netdev@vger.kernel.org>;
	Wed, 14 Nov 2012 09:26:37 +0100 (CET)
Received: from zimbra.karlsbakk.net (zimbra.karlsbakk.net [213.236.233.66])
	by zimbra.karlsbakk.net (Postfix) with ESMTP id D4FE0F5360
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 09:26:37 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

I've setup bonding on a few machines here. They're all blades in a Dell=
 blade chassis, so they're both connected to the four internal switches=
 (2 gigE, 2 10GigE). Using 10GigE only, I've setup bonding in active-ba=
ckup mode with the ARP driver. While this works well, we're planning ah=
ead for running IPv6 only.

Does anyone kow if something's in the works to allow redundant links in=
 an IPv6-only setup?

Please cc: to me as I'm not on the list

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
