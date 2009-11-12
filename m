From: "Marcus D. Leech" <mleech@ripnet.com>
Subject: SFP support for BCM54XX PHYs
Date: Thu, 12 Nov 2009 15:05:42 -0500
Message-ID: <4AFC6A96.20800@ripnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ripnet.com ([66.78.99.10]:3684 "EHLO mx1.ripnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273AbZKLUFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 15:05:38 -0500
Received: from localhost.localdomain (unverified [142.46.209.36]) by mx1.ripnet.com
  (Vircom SMTPRS 4.7.840.5) with ESMTP id <B0489051205@mx1.ripnet.com>
  (prot=TLS1-S cifer=RC4-128 hash=MD5-128 exch=RSA-1024 verify=NOT) for <netdev@vger.kernel.org>;
  Thu, 12 Nov 2009 15:05:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone gotten SFP support working for the BCM54XX series multi-mode 
PHYs using
   the ..drivers/net/phy/broadcom.c

I have a board that uses the BCM5464, and I need SFP to work.  Anyone 
done this?

Cheers
Marcus

