From: Kacper Bielecki <kazjote@stud.ics.p.lodz.pl>
Subject: Re: PROBLEM: network interface regularly stops working
Date: Tue, 3 Jul 2007 15:11:56 +0200
Message-ID: <200707031511.56583.kazjote@stud.ics.p.lodz.pl>
References: <200706051208.40929.kazjote@stud.ics.p.lodz.pl> <200706052147.02376.kazjote@stud.ics.p.lodz.pl> <20070605203709.GA26645@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stud.ics.p.lodz.pl ([212.51.220.231]:30718 "EHLO
	stud.ics.p.lodz.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbXGCNRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 09:17:11 -0400
In-Reply-To: <20070605203709.GA26645@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New kernel patch didn't solve my problem. 

I noticed also that number of packets dropped which is shown in ifconfig 
output increases always by 4294967295 no mather what time elapsed between two 
runs.
