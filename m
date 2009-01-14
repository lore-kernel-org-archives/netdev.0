From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for dma_debug_entries
Date: Wed, 14 Jan 2009 18:51:09 +0100
Message-ID: <20090114175109.GB11842@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-4-git-send-email-joerg.roedel@amd.com> <20090113005118.82f5037b.akpm@linux-foundation.org> <20090114114347.GG8625@elte.hu> <20090114093918.e7b0ae46.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, dwmw2@infradead.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-va3.frontbridge.com ([216.32.180.16]:63215 "EHLO
	VA3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbZANRve convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:51:34 -0500
Content-Disposition: inline
In-Reply-To: <20090114093918.e7b0ae46.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 09:39:18AM -0800, Andrew Morton wrote:
>=20
> Have we previously found bugs by other means which this facility woul=
d
> have detected?  I don't recall any...
>=20

See for example this bugfix:

http://www.spinics.net/lists/netdev/msg83208.html

The bug was found using the first version of this patchset.

Joerg


--=20
           | Advanced Micro Devices GmbH
 Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=C3=BCnchen
 System    |=20
 Research  | Gesch=C3=A4ftsf=C3=BChrer: Jochen Polster, Thomas M. McCoy=
, Giuliano Meroni
 Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=C3=BCnchen
           | Registergericht M=C3=BCnchen, HRB Nr. 43632

