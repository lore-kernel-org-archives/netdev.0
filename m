From: wit <is01kzh@gmail.com>
Subject: about multiple network interface
Date: Thu, 18 Oct 2007 21:06:40 +0800
Message-ID: <105610bf0710180606w6a687642r35414d2b66b6d3af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:25354 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597AbXJRNGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 09:06:42 -0400
Received: by py-out-1112.google.com with SMTP id u77so296528pyb
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 06:06:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

   Sorry, I don't know if this is the right mail list. I got the
following question:
   I have a e100 card and a e1000 card. Whenever I boot the system, I
found the eth0 matches the e1000 card, and the eth2 matches the other.
How can I force the eth0 to match the e100 card and the eth2 to match
e1000?
