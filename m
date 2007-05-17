From: "Latchesar Ionkov" <lucho@ionkov.net>
Subject: [PATCH][RFC]: v9fs: moving non-VFS related interfaces to net/
Date: Thu, 17 May 2007 08:50:43 -0600
Message-ID: <f158dc670705170750h464a1fb8x2ebe7724139fbd97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>,
	"Eric Van Hensbergen" <ericvh@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:60780 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417AbXEQOup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 10:50:45 -0400
Received: by an-out-0708.google.com with SMTP id d18so135955and
        for <netdev@vger.kernel.org>; Thu, 17 May 2007 07:50:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

It was suggested on lkml that we move the non-VFS layers of the 9P2000
protocol from fs/9p to net/9p making 9p usable for things other than
the VFS subsystem.

Can you please pull the patchset from
git://git.org/pub/scm/linux/kernel/git/ericvh/v9fs.git/ and review and
ack/reject it.

Thanks,
    Lucho
