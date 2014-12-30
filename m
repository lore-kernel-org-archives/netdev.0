From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: [Question] What's the noop_qdisc introduced for in the kernel?
Date: Tue, 30 Dec 2014 17:23:12 +0800
Message-ID: <CA+U0gVi=DTpz-Givbrs771+KYz8EE1ABdy2oO38q4LR9fG37YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:64396 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbaL3JXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 04:23:33 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so18991301pdi.3
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 01:23:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After google and the code reading, seems this Qdisc instance is only
used for the initialization purpose, I can't find the reason that this
object introduced in the kernel. Does anybody know what the historical
reason is for this invention? the purpose or the benefit for this
Qdisc object?

-- 
Den
