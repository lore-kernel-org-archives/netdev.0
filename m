From: "Miljanovic, Nebojsa (Neb)" <neb.miljanovic@alcatel-lucent.com>
Subject: Re:  [PATCH net-2.6.23] Per-datagram TTL and TOS via sendmsg()
Date: Thu, 9 Jun 2011 10:48:48 -0500
Message-ID: <180685543D224348869F70A5870DB9408A5EE802@USNAVSXCHMBSB2.ndc.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail3.lucent.com ([135.245.0.37]:46394 "EHLO
	ihemail3.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392Ab1FIPsw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 11:48:52 -0400
Received: from usnavsmail4.ndc.alcatel-lucent.com (usnavsmail4.ndc.alcatel-lucent.com [135.3.39.12])
	by ihemail3.lucent.com (8.13.8/IER-o) with ESMTP id p59Fmoom026340
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 9 Jun 2011 10:48:51 -0500 (CDT)
Received: from USNAVSXCHHUB01.ndc.alcatel-lucent.com (usnavsxchhub01.ndc.alcatel-lucent.com [135.3.39.110])
	by usnavsmail4.ndc.alcatel-lucent.com (8.14.3/8.14.3/GMO) with ESMTP id p59FmoFO016646
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 9 Jun 2011 10:48:50 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(re-submitting to the mailing list since I did not use plain text the first time around)

Hello David,

is there any way to get this old PATCH accepted. I am finding it very useful since the only other way to control TOS/DSCP is via socket option. However, socket wide TOS/DSCP is not always practical. Having ability for applications to control TOS/DSCP on per-datagram basis is so much more powerful.


http://marc.info/?l=linux-netdev&m=118388241201593

 
Thanks,
Neb Miljanovic
Alcatel-Lucent

 
