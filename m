From: "Hua Zhong" <hzhong@gmail.com>
Subject: tcp write returns 0?
Date: Thu, 21 Aug 2008 12:06:28 -0700
Message-ID: <007901c903c1$044b8780$0ce29680$@com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:39827 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbYHUTGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 15:06:42 -0400
Received: by gxk9 with SMTP id 9so569352gxk.13
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 12:06:41 -0700 (PDT)
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Under what condition would tcp write return 0?

Especially since a previous poll() indicates the socket is writable. Could
this only happen for socket in NONBLOCK mode?

Thanks.

Hua

