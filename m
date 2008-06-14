From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 1/2] 8139too: clean up spaces and TABs
Date: Sat, 14 Jun 2008 15:33:33 +0200
Message-ID: <4853C8AD.9020407@s5r6.in-berlin.de>
References: <4853BB62.1060109@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:57842 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbYFNNfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 09:35:04 -0400
In-Reply-To: <4853BB62.1060109@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

N=E9meth M=E1rton wrote:
> -/* The following settings are log_2(bytes)-4:  0 =3D=3D 16 bytes .. =
6=3D=3D1024, 7=3D=3Dend of packet. */
> +/* The following settings are log_2(bytes)-4:
> +   0 =3D=3D 16 bytes .. 6=3D=3D1024, 7=3D=3Dend of packet. */

We don't write comments like this.
--=20
Stefan Richter
-=3D=3D=3D=3D=3D-=3D=3D--- -=3D=3D- -=3D=3D=3D-
http://arcgraph.de/sr/
