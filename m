From: Sven Anders <anders@anduras.de>
Subject: Re: Realtek 8139 Flow Control?
Date: Wed, 27 Jul 2011 14:29:49 +0200
Message-ID: <4E3004BD.4090705@anduras.de>
References: <4E2DC710.5000100@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050709060906080301020102"
Cc: jgarzik@pobox.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailr01.anduras.de ([89.28.138.12]:56433 "EHLO
	mailr01.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab1G0M3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 08:29:50 -0400
In-Reply-To: <4E2DC710.5000100@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050709060906080301020102
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Sven Anders wrote:
> I have just a short question.
> 
> We have appliances with Realtek 8139C/8139C+ (rev 10) chipsets (with the
> PCI IDs: 10ec:8139). We are using the 8139too driver (version: 0.9.28)
> According the datasheet the chipset supports Flow Control (IEEE 802.3x).
> 
> I want to know, if the support for enabling flow control is missing in
> the driver by purpose or is only not implemented due to lack of time?

Hi, again!

Can somebody of the old implementors please answer this question?

We need that feature and I'm willing to implement it, but I need the
confirmation, that it was not done due to lack of time and not because
will not work (correctly)...

Regards
 Sven Anders

-- 
 Sven Anders <anders@anduras.de>                 () UTF-8 Ribbon Campaign
                                                 /\ Support plain text e-mail
 ANDURAS intranet security AG
 Messestrasse 3 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 50-55

Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.
  - Benjamin Franklin

--------------050709060906080301020102
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Messestra=C3=9Fe 3;Passau;Bavaria;94036;Germany
email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------050709060906080301020102--
