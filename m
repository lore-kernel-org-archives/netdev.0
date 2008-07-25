From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: forcedeth mac reversed again via kexec
Date: Fri, 25 Jul 2008 13:47:05 -0700
Message-ID: <86802c440807251347x424b14d4j663928922a507d9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nedev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Ayaz Abdulla" <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:63857 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbYGYUrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 16:47:06 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3602764rvb.1
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 13:47:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mac address ordering get reversed again by kexec path in second kernel
in current linus tree
it is ck804 system

YH
