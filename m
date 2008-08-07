From: "Aleksey Senin" <aleksey.senin@gmail.com>
Subject: Is this necessary export ndisc_send_ns
Date: Thu, 7 Aug 2008 11:01:58 +0300
Message-ID: <118191fa0808070101h94eb4b5rd94cdc457b1fa8e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:61519 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbYHGIB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 04:01:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so351858rvb.1
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 01:01:59 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all!
I'm working on IPv6 support for Ininiband stack and some module need
to perform network discovery. Is there a way to do it without
exporting symbol ndisc_send_ns?
