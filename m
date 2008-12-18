From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 0/3] NIU: Implement discard counters
Date: Thu, 18 Dec 2008 14:52:11 +0100
Message-ID: <1229608331.16904.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hawk@comx.dk, Robert Olsson <Robert.Olsson@data.slu.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36699 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbYLRNwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 08:52:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series implements discard counter stats for the NIU driver.

This work has been done together with Robert Olsson.  We have come to a
stage where the patches needs public review, and possible discussion.

Tested with hardware:
 Sun Quad GbE x8 PCIe
 Sun Dual 10GbE XFP PCIe

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

