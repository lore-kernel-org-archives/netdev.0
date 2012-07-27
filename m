From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH v2 0/7] TCP Fast Open client
Date: Fri, 27 Jul 2012 12:52:47 -0700
Message-ID: <CAGK4HS9ZRV+JFDnQnRyxDzk45W-PtpNk1BfRd2B4kQpNfHf+xw@mail.gmail.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	<CAHO5Pa0D-hS=zdEEyUWMN6bmpKvQgiy25nTu1=BUYVxec+zpsQ@mail.gmail.com>
	<CAPshTCjxUQ=juO3POX1oSaLTO_g3EmxjQNkSxLjEZGyxDBkMJQ@mail.gmail.com>
	<CAHO5Pa3eLRrjGx52o26sN9OS7PMbKu3e3=Zz72E7Z6i5XwDnvw@mail.gmail.com>
	<CAPshTCgR585z5sFUbxgR5azb2kZe2mnx=x6i_0M=iint5NEpJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, davem@davemloft.net,
	edumazet@google.com, ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org, rick jones <perfgeek@mac.com>,
	Terry Lam <vtlam@cs.ucsd.edu>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:32836 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431Ab2G0Tws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 15:52:48 -0400
Received: by obbuo13 with SMTP id uo13so4723640obb.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 12:52:47 -0700 (PDT)
In-Reply-To: <CAPshTCgR585z5sFUbxgR5azb2kZe2mnx=x6i_0M=iint5NEpJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Anyway hopefully the code will be ready for review soon (i'm leaving for
> vacation in a few days so it will be a little more delay). If you can't wait to
> test it i can send you a patch.
>

Jerry,
If you don't mind, can you CC me the patches too if they are ready? I
was planning to test TFO too and was waiting for the server side
patches,
For the user space, as far as I understand, replacing connect() with
sendmsg() with MSG_FASTOPEN  flag should be the only change needed
right?

Thanks,
Vijay
