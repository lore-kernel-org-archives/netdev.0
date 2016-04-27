From: Otto Sabart <osabart@redhat.com>
Subject: ixgbe: cannot enable LRO
Date: Wed, 27 Apr 2016 11:36:46 +0200
Message-ID: <20160427093646.GA15205@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="rwEMma7ioTxnRzrJ"
Cc: Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026AbcD0Jgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 05:36:48 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A1A4F3B752
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:36:47 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hello everyone,
does anybody have a problem with LRO on ixge (on latest 4.6-rc5)?
I cannot find a way to enable it.

On stable RHEL7.2 kernel everything works fine.

I opened a bug report [0].

[0] https://bugzilla.kernel.org/show_bug.cgi?id=117291


Thanks!

Ota

--rwEMma7ioTxnRzrJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJNBAABCgA3BQJXIIgsMBSAAAAAABUAEnBrYS1hZGRyZXNzQGdudXBnLm9yZ29z
YWJhcnRAcmVkaGF0LmNvbQAKCRCCO66Z+L4ePKWcD/0c3t5ue1X//Crw8XOwYodt
N++zB/iPFntG9k5qTblzijm3qC/lHflkqN0DKBFGq88oj/T+UjNk6QLAjtPinz/w
5qNja7XaaN2lGDQvvV0sEHEdozAkG/wBCM6Vop6emIeUbLL9r2Mypt76raAJ9TnT
WkxccNSz25Pbe1QEiw8RjRz+xRvlfv5AW/669/f/DgT4VTrOmMdWfabVlQT3fr+0
Kyp0mYRULBMWy/TqDUHgiH1gvSqoZhm/a1yphM/QFHWraivGKWia6pEU3Yqy9Kqf
r47VHhMRCId3lKM9ee8/h4F5qf20LsqeCa5q02Ezwcvl2Ppuymte/GrVIATEeQFl
Wiq5t2QzFhd/WIYBjUdZ7nlIv9a09Y4r4HAYSC/j8M9Ikbj9h+uPWn3UOj3V0Iic
aDZRFeujeL9GO3xFpdqsdx248dWkXHd/FGEZ0+XDNuzayHTi8a0lou/hZH+rAfgg
JC4gvIrPUMkBmsuaX9qgCrXfnKI23V6hm5ZzTueKAuFPbA3JBZFEyNWxW8xUmni6
3pWhPhA7HyQZjeS6AvwxY/pbaqJmOcwfQdm8q4Y9HrfVFNzs4Uj3bZrSf6vm1OtH
NBV6hfAYLFlkrtrrJIMPFLsid/EQd8nbj1qKMESE/RVBQaXbwgo2J1aVV9uWbYnZ
AN0v8isRR/EiPMA5lDLVBA==
=QA7H
-----END PGP SIGNATURE-----

--rwEMma7ioTxnRzrJ--
