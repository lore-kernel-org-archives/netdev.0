From: "Jiri Klimes" <klimes@centrum.cz>
Subject: Re: 'ip' command should allow creation of an IPsec SA with 'proto any' and specified sport and dport as selectors
Date: Fri, 24 Apr 2009 15:15:18 +0200
Message-ID: <200904241515.6341@centrum.cz>
References: <200904241309.13171@centrum.cz> <200904241311.14474@centrum.cz> <20090424.044938.57356604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-------=_383B1C78.419929E6"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1010.centrum.cz ([90.183.38.140]:33155 "EHLO
	mail1010.centrum.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbZDXNfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 09:35:23 -0400
Received: by mail1010.centrum.cz id S1074311216AbZDXNPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 15:15:18 +0200
In-Reply-To: <20090424.044938.57356604.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format

---------=_383B1C78.419929E6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

______________________________________________________________
> Od: davem@davemloft.net
> Komu: klimes@centrum.cz
> CC: netdev@vger.kernel.org
> Datum: 24.04.2009 13:49
> Předmět: Re: 'ip' command should allow creation of an IPsec SA with 'proto any' and specified sport and dport as selectors
>
>From: "Jiri Klimes" <klimes@centrum.cz>
>Date: Fri, 24 Apr 2009 13:11:34 +0200
>
>> please find a patch in the attachment.
>
>There is no attachment.
>

oops, sorry.
Forgot the most important.



---------=_383B1C78.419929E6
Content-Type: text/x-patch; name="ip_sa.patch"
Content-Transfer-Encoding: base64

LS0tIGEvaXAvaXB4ZnJtLmMKKysrIGIvaXAvaXB4ZnJtLmMKQEAgLTExNTYsNiArMTE1Niw3
IEBAIHN0YXRpYyBpbnQgeGZybV9zZWxlY3Rvcl91cHNwZWNfcGFyc2Uoc3RydWN0IHhmcm1f
c2VsZWN0b3IgKnNlbCwKICAgICAgICAgICAgICAgIGNhc2UgSVBQUk9UT19VRFA6CiAgICAg
ICAgICAgICAgICBjYXNlIElQUFJPVE9fU0NUUDoKICAgICAgICAgICAgICAgIGNhc2UgSVBQ
Uk9UT19EQ0NQOgorICAgICAgICAgICAgICAgY2FzZSBJUFBST1RPX0lQOiAgLyogdG8gYWxs
b3cgc2hhcmVkIFNBIGZvciBkaWZmZXJlbnQgcHJvdG9jb2xzICovCiAgICAgICAgICAgICAg
ICAgICAgICAgIGJyZWFrOwogICAgICAgICAgICAgICAgZGVmYXVsdDoKICAgICAgICAgICAg
ICAgICAgICAgICAgZnByaW50ZihzdGRlcnIsICJcInNwb3J0XCIgYW5kIFwiZHBvcnRcIiBh
cmUgaW52YWxpZCB3aXRoIHByb3RvPSVzXG4iLCBzdHJ4Zl9wcm90byhzZWwtPnByb3RvKSk7
Cg==

---------=_383B1C78.419929E6--
