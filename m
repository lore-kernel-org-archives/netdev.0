From: byungho an <bh74an@gmail.com>
Subject: Regarding ethernet dir
Date: Tue, 11 Sep 2012 23:37:50 +0900
Message-ID: <CAG4h5ywMFfDK-wdseTL0Tq0=jxbB_OxT1-3W_ef3ksO38fJLMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:45418 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522Ab2IKOhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 10:37:51 -0400
Received: by oago6 with SMTP id o6so277753oag.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 07:37:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have one suggestion for ethernet dir.
Currently It is well-defined and good for management.

But if IP vendor is different from SoC vender, It is a bit confusing
to guess dir name.
For example, stmmac is using Synopsys dwmac.
In this case, if another SoC vendors try to use Synopsys IP, they
sould make their own dir under the their name?

If there is common dir of IP vendor, It would be more clear like below.

What do you think about it?
I want to exchange opinion and find a resonable and rational way.

Thank you.
Andy.
