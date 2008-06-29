From: "Aleksey Senin" <aleksey.senin@gmail.com>
Subject: ip_dev_find alternative for ipv6
Date: Sun, 29 Jun 2008 13:53:53 +0300
Message-ID: <118191fa0806290353k4e33d7a9sdb88aca6dda59ccd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:20272 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428AbYF2Kxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 06:53:53 -0400
Received: by yw-out-2324.google.com with SMTP id 9so532642ywe.1
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2008 03:53:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
what is the best alternative for ip_dev_find when porting existing
functions from ipv4 to ipv6, if exist. But probably the right question
is - How should be implemented searching of HW address by given IP
address.
