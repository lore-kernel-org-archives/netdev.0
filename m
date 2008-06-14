From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Sat, 14 Jun 2008 23:23:41 +0200
Message-ID: <20080614212341.GA12976@electric-eye.fr.zoreil.com>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57345 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755032AbYFNVxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:53:33 -0400
Content-Disposition: inline
In-Reply-To: <20080604215909.GA17446@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu <romieu@fr.zoreil.com> :
[...context available from http://lkml.org/lkml/2008/5/31/251 ...]

R=C3=A9gis, I need your help.

Can you give the patchkit below a try and check if the change of mtu
works correctly ?

http://userweb.kernel.org/~romieu/via-velocity/2.6.26-rc6/

or:

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git vel=
ocity

--=20
Ueimor
