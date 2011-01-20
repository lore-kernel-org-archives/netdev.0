From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: MultiPath TCP in the Linux Kernel
Date: Thu, 20 Jan 2011 15:09:34 +0100
Message-ID: <201101201509.34536.christoph.paasch@uclouvain.be>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35341 "EHLO
	smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559Ab1ATOLV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 09:11:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

The IETF is developing a new transport layer solution, MultiPath TCP, w=
hich=20
allows to efficiently exploit several Internet paths between a pair of =
hosts,=20
while presenting a single TCP connection to the application layer.

At the UCLouvain in Belgium we are developping the support for MultiPat=
h TCP=20
in the Linux Kernel. The implementation is a major extension to the Lin=
ux TCP-
stack.

=46or general information, access:
http://inl.info.ucl.ac.be/mptcp
https://scm.info.ucl.ac.be/trac/mptcp/

To access the git-repository:
git://scm.info.ucl.ac.be/mtcp.git
branches:
	mptcp_2.6.36 - based on Linux Kernel 2.6.36
	mtcp_no_subrcvqueue - based on Linux Kernel 2.6.28

=46or questions, feedback,... feel free to subscribe to the mptcp-dev M=
ailing-
List:
https://listes-2.sipr.ucl.ac.be/sympa/info/mptcp-dev


Regards,
Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
