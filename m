From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: [ANNOUNCE] 10GbE Xframe-II ASIC Programming Manual
Date: Wed, 27 Dec 2006 14:15:28 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701080E4D@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60031 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbWL0TPj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 14:15:39 -0500
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 5667620048B2
	for <netdev@vger.kernel.org>; Wed, 27 Dec 2006 14:15:39 -0500 (EST)
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ASIC Programming Manual (aka Device Driver Guide) got updated to
match current feature set of s2io driver, and posted at
http://trac.neterion.com/cgi-bin/trac.cgi/wiki/TitleIndex?anonymous
under "Documentation Download" (Xframe_II_OSDDG_2.1_LE.pdf). 

Some noteworthy updates include Chapter C Application notes on features
like interrupt moderation and multi-queue receive traffic steering. Only
little endian file is posted at present; if someone is interested in big
endian flavor of the register map please e-mail to support@neterion.com,
and we will generate and post the BE pdf.


