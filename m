From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 0/4] Adds implementation of TFRC-SP  sender side into the
 DCCP test tree
Date: Tue, 13 Oct 2009 14:19:46 -0300
Message-ID: <4AD4B6B2.1020502@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivocalado@embedded.ufcg.edu.br
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedded.ufcg.edu.br ([150.165.63.2]:11942 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760659AbZJMRUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:20:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches adds implementation of TFRC-SP at the sender side, and are targeted at the DCCP branch.



Patch #1: Adds random ect generation to tfrc-sp sender side
Patch #2: Implement function that allows to keep track of packets sent in last 2 rtt
Patch #3: Implement dropped packets option
Patch #4: Implement loss intervals option


--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab -
http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center -
http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.



