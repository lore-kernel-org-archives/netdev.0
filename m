From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 0/7] Updated patchset w/James' comments
Date: Mon, 17 Jul 2006 14:48:17 -0400
Message-ID: <200607171848.k6HImHUG020102@turing-police.cc.vt.edu>
References: <20060717155224.060020000@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1153162097_13479P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:17121 "EHLO
	turing-police.cc.vt.edu") by vger.kernel.org with ESMTP
	id S1750732AbWGQSsi (ORCPT <RFC822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 14:48:38 -0400
To: paul.moore@hp.com
In-Reply-To: Your message of "Mon, 17 Jul 2006 11:52:24 EDT."
             <20060717155224.060020000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1153162097_13479P
Content-Type: text/plain; charset=us-ascii

On Mon, 17 Jul 2006 11:52:24 EDT, paul.moore@hp.com said:
> Some changes in the patchset based on James Morris' comments over the weekend, in
> addition I rebased the patchset against 2.6.18-rc2.

Minor comment - can you start posting these with Subject: lines that
say something like:

Subject: [Patch X/Y] NetLabel-VNN:

Where 'NN' gets incremented each time you post?  I almost got myself a
patch set in my "to look at" queue that was half Friday's and half today's,
and no good could have come from that. And yes, it's *ok* if Friday's was
-v14 and today is -v15, if we're making progress towards merge-able code.. ;)

(Venkat - I'm cc'ing you as I've seen the same thing with MLSXFRM patchsets)...


--==_Exmh_1153162097_13479P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFEu9twcC3lWbTT17ARAgKnAKC4oRhPvFuagMv4Va+JY90L4Al46gCg6u6A
XuLtekHuyI/VaQLGCEf3i6w=
=1U6o
-----END PGP SIGNATURE-----

--==_Exmh_1153162097_13479P--
