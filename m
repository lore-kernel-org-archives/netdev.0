From: Masashi Honma <masashi.honma@gmail.com>
Subject: Where is a git tree for submitting patch
Date: Wed, 6 Jul 2016 10:35:39 +0900
Message-ID: <577C606B.5060703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33912 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbcGFBfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 21:35:42 -0400
Received: by mail-pf0-f196.google.com with SMTP id 66so20399570pfy.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 18:35:41 -0700 (PDT)
Received: from [192.168.3.20] (p0347f3.kngwnt01.ap.so-net.ne.jp. [121.3.71.243])
        by smtp.googlemail.com with ESMTPSA id qc6sm610928pac.6.2016.07.05.18.35.40
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 18:35:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though I have made a patch to netdev, kbuild failed.

The kbuild failed with the file "net/netlabel/netlabel_calipso.c".

Though I watched below two trees, there was not such a file.

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/tree/net/netlabel
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/net/netlabel

Where is a correct tree ?

Regards,
Masashi Honma.
