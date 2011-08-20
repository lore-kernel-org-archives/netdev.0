From: =?UTF-8?B?RMOibmllbA==?= Fraga <fragabr@gmail.com>
Subject: inetd and Linux kernel 3.0
Date: Sat, 20 Aug 2011 19:29:54 -0300
Message-ID: <4e503565.28b8ec0a.650c.5823@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:65185 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953Ab1HTW36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 18:29:58 -0400
Received: by yxj19 with SMTP id 19so2869949yxj.19
        for <netdev@vger.kernel.org>; Sat, 20 Aug 2011 15:29:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi, I upgraded to Linux kernel 3.0 and now I have the following
message on the log:

Aug 19 23:22:13 tux inetd[3143]: nntp/tcp: bind: Address family not
supported by protocol

	With kernel 2.6.39 everything worked fine. Is it a problem with
inetd? Maybe some incompatibility?

	Thanks.

	Ps: I asked here, because inetutils maintainer didn't reply me
and I couldn't fine anything on Google. Maybe you can give me some hint
or workaround.

-- 
