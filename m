From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCHv2 0/4] Adds implementation of TFRC-SP receiver side into the
 DCCP test tree
Date: Tue, 13 Oct 2009 14:18:34 -0300
Message-ID: <4AD4B66A.8010605@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivocalado@embedded.ufcg.edu.br
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from embedded.ufcg.edu.br ([150.165.63.2]:50297 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760625AbZJMRTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:19:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches adds implementation of TFRC-SP receiver side, and
are targeted at the DCCP branch.



Patch #1: First Patch on TFRC-SP. Copy base files from TFRC
Patch #2: Implement loss counting on TFRC-SP receiver
Patch #3: Implement TFRC-SP calc of mean length of loss intervals
accordingly to section 3 of RFC 4828
Patch #4: Adds options DROPPED PACKETS and LOSS INTERVALS to receiver


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


