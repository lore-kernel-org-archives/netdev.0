From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ANNOUNCE] iproute2 v2.6.28
Date: Thu, 15 Jan 2009 13:08:45 -0800
Message-ID: <20090115130845.01d7ebf4@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60259 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934163AbZAOVIt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 16:08:49 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id A18DC4F48E8
	for <netdev@vger.kernel.org>; Thu, 15 Jan 2009 13:08:52 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EV6k65CfbK+I for <netdev@vger.kernel.org>;
	Thu, 15 Jan 2009 13:08:48 -0800 (PST)
Received: from extreme (pool-96-225-207-155.ptldor.fios.verizon.net [96.225.207.155])
	by mail.vyatta.com (Postfix) with ESMTP id 9C7E64F48DF
	for <netdev@vger.kernel.org>; Thu, 15 Jan 2009 13:08:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New version of iproute2 utilities that includes bug fixes and
support for all the new features in kernel 2.6.28.

Source: (note old developer.osdl.org address works as well)
	http://devresources.linux-foundation.org/dev/iproute2/download/iproute=
2-2.6.28.tar.bz2

Git tree:
	git://git.kernel.org/pub/scm/network/iproute2/iproute2.git

Changes since v.2.6.27:

Alexander Duyck (2):
      add support for skbedit action
      add support for multiq qdisc

Benedikt Gollatz (1):
      When the preferred lifetime of a prefix assigned by IPv6 autoconf=
iguration

Denys Fedoryshchenko (1):
      Fix tc/m_ipt memory leaks

Herbert Xu (2):
      ip: gre: Add GRE configuration support through rtnl_link
      Update version of IP gre

Olivier Fourdan (1):
      ip maddr show=E2=80=9D on an infiniband address causes a stack co=
rruption

Stephen Hemminger (4):
      Update headers to 2.6.28
      Fix leftovers from earlier change
      Fix compile warnings
      Update snapshot

