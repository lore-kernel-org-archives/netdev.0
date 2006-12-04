From: "prajakta choudhari" <prajaktachoudhari@gmail.com>
Subject: help regarding ip address assignment in kernel module
Date: Mon, 4 Dec 2006 10:36:51 +0530
Message-ID: <e9010580612032106p30f561f7h999acaf2f5255aa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:33534 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1759819AbWLDFGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 00:06:52 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1796949nze
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 21:06:52 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:
I am absolutely new to kernel module programming. I have to modify the
hostap -code such that whenever a network device is registered, it is
assigned an ip address.

can i some how use the devinet.c functions such as
inetdev_init,inet_insert_ifa,etc fucntions even though they are not
exported, if so how.

Thank you


-- 
-------------------------------------
-------------------------------------
Regards,
Prajakta Choudhari,
