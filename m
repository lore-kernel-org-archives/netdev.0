From: Clemens Brunner <clemens.brunner@tugraz.at>
Subject: No network on Asus P5B (r8169)
Date: Tue, 10 Jul 2007 18:45:24 +0200
Message-ID: <200707101845.24297.clemens.brunner@tugraz.at>
References: <20070628234222.GA8180@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay.tu-graz.ac.at ([129.27.2.202]:57796 "EHLO
	mailrelay.tugraz.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449AbXGJRqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 13:46:46 -0400
In-Reply-To: <20070628234222.GA8180@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I just found out that everything is working just fine with a 64-bit Linux 
kernel. I hope this helps you hunt down the error in the 32-bit version.
https://bugzilla.novell.com/show_bug.cgi?id=288406

Clemens
