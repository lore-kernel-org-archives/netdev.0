From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: Re: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Mon, 05 Nov 2007 16:17:10 +0100
Message-ID: <472F33F6.8010501@ext.bull.net>
References: <471C893F.6000306@ext.bull.net> <18214.46206.94270.229728@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42764 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbXKEPQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 10:16:29 -0500
In-Reply-To: <18214.46206.94270.229728@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil,
Thank you for the reply.

Neil Brown wrote:

>>I think this patch is unnecessary and hence not wanted.
>>The getfs / getfs calls should be considered legacy calls.
>>Adding functionality to them is not appropriate.
>>   =20
>>
I agree with that.
But I don't think we really add functionality here.
Modifications are just necessary to match the auth_unix_lookup new=20
prototype.
I don't see how we can avoid that.

Aur=E9lien

--=20

********************************
       Aurelien Charbon
       Linux NFSv4 team
           Bull SAS
     Echirolles - France
http://nfsv4.bullopensource.org/
********************************

