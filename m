From: =?UTF-8?B?UmljaGFyZCBSw7ZqZm9ycw==?= <richard.rojfors@endian.se>
Subject: Re: SMC91x: forcing speed
Date: Thu, 04 Jun 2009 17:02:36 +0200
Message-ID: <4A27E20C.4020603@endian.se>
References: <ba4215e10906040608m36538458u60a7971834f26d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, netdev@vger.kernel.org
To: Martin Fuzzey <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-2-sn2.hy.skanova.net ([81.228.8.180]:38930 "EHLO
	av9-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbZFDPZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 11:25:34 -0400
In-Reply-To: <ba4215e10906040608m36538458u60a7971834f26d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Martin Fuzzey wrote:
> Hi,
> 
> Is there a better way of doing this that would be acceptable for mainline?

Look at include/linux/ethtool.h.

- --Richard
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkon4gsACgkQ9yPqN8x056fEFQCgi2+3de3djG0JyjBJmSO1fiKa
lyYAn3hVMRxf75PcYNK0EFjx6fJE9YK/
=8fR/
-----END PGP SIGNATURE-----
