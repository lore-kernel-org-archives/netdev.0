From: Niklas Cassel <niklas.cassel@axis.com>
Subject: stmmac DT property snps,axi_all
Date: Mon, 5 Dec 2016 17:18:33 +0100
Message-ID: <51f8249e-bdb9-e3a7-5d82-7ac869316f0e@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:59005 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751845AbcLEQSf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 11:18:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Giuseppe


I'm trying to figure out what snps,axi_all is supposed to represent.

It appears that the value is saved, but never used in the code.

Looking at the register specification, I'm guessing that it represents
Address-Aligned Beats, but there is already the property snps,aal
for that.


Regards,
Niklas
