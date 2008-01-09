From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 9 Jan 2008 10:36:38 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801091034390.27051@bizon.gios.gov.pl>
References: <11997574203125-git-send-email-fubar@us.ibm.com>
 <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death>
 <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-653894207-1199871398=:27051"
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:40764 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbYAIKRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 05:17:34 -0500
In-Reply-To: <17850.1199865514@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-653894207-1199871398=:27051
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 8 Jan 2008, Jay Vosburgh wrote:

> Krzysztof Oledzki <olel@ans.pl> wrote:
>
>> Fine. Just let you know that someone test your patches and everything
>> works, except mentioned problem.
>
> =09And I appreciate it; I just wanted to make sure our many fans
> following along at home didn't misunderstand.
>
> =09Could you let me know if the patch below make the lockdep
> warning go away?  This applies on top of the previous three, although it
> should be trivial to do by hand.
>
> =09I'm still checking to make sure this is safe with regard to
> mutexing the bonding structures, but it would be good to know if it
> eliminates the warning.

I can confirm that the warning went away.

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-653894207-1199871398=:27051--
