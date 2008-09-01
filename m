From: "Bosko Radivojevic" <bosko.radivojevic@gmail.com>
Subject: GRE keepalive support
Date: Mon, 1 Sep 2008 12:32:56 +0200
Message-ID: <d6c8ef150809010332g4760d893wcc09188e02ed2a2f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:65442 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbYIAKc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 06:32:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1736313rvb.1
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2008 03:32:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I hope I'm sending this question to the right mailing list(s).

After a few hours of googling I realized that there is no support for
GRE keepalives in Linux. Or, better to say, GRE keepalives are Cisco's
"proprietary" feature.

The project I'm currently working for needs GRE keepalives on Linux
side (besides possibility to run some routing protocol over GRE) in
order to have "link state" information. It looks implementing that
feature on Linux is not too complicated and I'll give a try. Are there
any obstacles I'm currently unable to see? Maybe there is a reason why
GRE keepalives are not implemented? Except lack of detailed
documentation :)

So, any comments are welcome.

Thanks!
