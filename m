From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH v7 00/17] Labeled networking patches for 2.6.28
Date: Mon, 06 Oct 2008 15:19:41 -0400
Message-ID: <20081006191516.15686.80823.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You will notice the lack of a "RFC" prefix to this patchset, that is because
this should be the last revision prior to the 2.6.28 merge window opening.
The changes between v6 and v7 are very minor and mostly involve sparse
fixes and the conversion of some "magic" numbers in net/ipv4/cipso_ipv4.c
to constants defined in the CIPSO header file.  I just updated both the
lblnet-2.6_{testing,next} git trees so anyone interested should feel free
to grab the latest bits from here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing

Thanks to everyone who has helped review and test these patches.

--
paul moore
linux @ hp
