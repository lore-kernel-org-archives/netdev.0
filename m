From: Ming-Ching Tiew <mctiew@yahoo.com>
Subject: Linux arp flux problem
Date: Sun, 11 Apr 2010 20:16:29 -0700 (PDT)
Message-ID: <908408.23515.qm@web31502.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31502.mail.mud.yahoo.com ([68.142.198.131]:42953 "HELO
	web31502.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751965Ab0DLDXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 23:23:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following link explains the Linux arp flux problem pretty well, and I myself have been burnt badly by a life site where the "arp_filter" does not help at all.

         http://linux-ip.net/html/ether-arp.html

And I tested the kernel patch by Julian Anastasov, and it works 100% reliably :-

         http://www.ssi.bg/~ja/#hidden

My question is the patches has been around for many years, why has it not been included into the kernel ? Is it that Linux is supposed to have this "side effects" of arp linux on purpose ?

Best regards.


      
