From: "David S. Miller" <davem@redhat.com>
Subject: 2.4.x IPSEC backport available
Date: Sun, 11 May 2003 14:46:21 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030511.144621.35018826.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-kernel@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is a 2.4.x backport of IPSEC available.  However there is a
STRONG caveat about using these changes in that we absolutely refuse
to take bug reports against this release, 2.5.x is where the active
development is taking place and thus where the testing is supposed to
take place.

This patch is a convenience for people, and nothing more.

Fetch it from:

	ftp://ftp.kernel.org/pub/linux/kernel/davem/IPSEC/linux-2.4.21-ipsec.patch
	bk://kernel.bkbits.net/davem/ipsec-2.4/

Enjoy.
