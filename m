From: Marcus Wermuth <marcus.wermuth@gmail.com>
Subject: netem: Gilbert, Simple Gilbert, Bernouli loss model broken
Date: Tue, 8 Nov 2011 12:40:29 +0100
Message-ID: <CAFXUZ_G7oAT9v1B4NNm5c2nxUpU_-zXNV47XzcyKNKgsDLjQzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:60346 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177Ab1KHLkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 06:40:31 -0500
Received: by qyk27 with SMTP id 27so3517965qyk.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 03:40:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I wanted to try the netem extension to setup a loss via Gilbert,
Simple Gilbert, Bernouli loss model[1]. Kernel support is included
since several releases. But configuration as demonstrated in [1] does
not work at all. It seems that the userspace part in iproute is
missing, the original patch from the authors does not work.

Does anybody know about that?

Bye, Marcus

(I'm not subscribed to netdev-list)

[1] http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG
