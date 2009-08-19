From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: bnx2: module problem with 2.6.30.y or later
Date: Wed, 19 Aug 2009 21:00:17 +0900
Message-ID: <5e93dcec0908190500t77ce7f57u4e78ec3f37332604@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ryota OZAKI <ozaki.ryota@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:52692 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZHSMAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 08:00:16 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1451710qwh.37
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 05:00:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm facing a problem that my kernel freezes on kexec
with bnx2 configured as a module. A workaround embedding
it and its firmware into the kernel makes out as
it was reported somewhere. However, I want to compile
it as a module due to our system limitation.

Is anyone working on the problem?

The problem appears with 2.6.30.y and 2.6.31-rc? and
not with 2.6.29.y.

Thanks,
  ozaki-r
