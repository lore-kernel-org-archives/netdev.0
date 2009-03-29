From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bnx2, 2.6.29, smp_affinity strangeness
Date: Sun, 29 Mar 2009 04:35:33 +0200
Message-ID: <49CEDE75.1030606@cosmosbay.com>
References: <200903290447.58338.denys@visp.net.lb> <200903290527.49029.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44795 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755953AbZC2Cfk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 22:35:40 -0400
In-Reply-To: <200903290527.49029.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko a =E9crit :
> Forgot to tell
> kernel 2.6.29 x86_64
> userspace is 32-bit
>=20
> I test also 32-bit kernel/32-bit userspace - same result.
>=20
> On Sunday 29 March 2009 04:47:58 Denys Fedoryschenko wrote:
>> While running bnx2 tried to assign affinity to network card and ... =
failed.
> --


Yes I hit this too in the past

http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-11/msg01398.html


