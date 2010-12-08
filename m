From: wisalsami <wisalsami@yahoo.co.uk>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Tue, 7 Dec 2010 23:31:30 -0800 (PST)
Message-ID: <30403215.post@talk.nabble.com>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <1156345366
 3761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org> <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-em
 ail-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org> <11563453674194-git-send-email-yoshfuji@linux-ipv6.org> <11563453671463-git-send-email-yoshfuji@linux-ipv6.org> <11563453672872-git-send-email-yoshfuji@linux-ipv6.org> <11563453671273-git-send-email-yoshfuji@linux-ipv6.org> <11563453674024-git-send-email-yoshfuji@linux-ipv6.org> <11563453673854-git-send-email-yoshfuji@li
 nux-ipv6.org> <11563453681815-git-send-email-yoshfuji@linux-ipv6.org> <11563453682841-git-send-email-yoshfuji@linux-ipv6.org> <20060823.225706.03601250.davem@davemloft.net> <20060824.150442.44820672.yoshfuji@linux-ipv6.org> <20060823.235404.108743952.davem@davemloft.net> <44ED4FC3.9060005@linux-ipv6.org> <20060824.045850.74749237.davem@davemloft.net> <44EE4ABC.6050604@linux-ipv6.org> <44EECBB0.7070001@linux-ipv6.org> <20060825.031651.88475974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kuber.nabble.com ([216.139.236.158]:40001 "EHLO
	kuber.nabble.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab0LHHbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 02:31:31 -0500
Received: from isper.nabble.com ([192.168.236.156])
	by kuber.nabble.com with esmtp (Exim 4.63)
	(envelope-from <lists@nabble.com>)
	id 1PQEUs-00022w-G9
	for netdev@vger.kernel.org; Tue, 07 Dec 2010 23:31:30 -0800
In-Reply-To: <20060825.031651.88475974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
I m started working on vertical handover, and also got the patch
(NIST_Mobility) working on ns-2.29 (but it doesn't matter its not 2.29). But
i m new to this subject, so i need some help, that how should i implement
MIPL on ns-2. or have you worked on NIST_Mobility patch on ns, that whether
nist_mobility patch support mipl and mipv6 or not.
because i found a header file name as "mip6.h"

could you help me in this topic, if not, then if you direct me to someone.

reards
Wisal Sami
wisalsami@yahoo.co.uk
-- 
View this message in context: http://old.nabble.com/-PATCH-0-44--Mobile-IPv6-Platform%2C-Take-2-%28for-net-2.6.19%29-tp5946388p30403215.html
Sent from the netdev mailing list archive at Nabble.com.

