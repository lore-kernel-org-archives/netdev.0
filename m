From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Tue, 2 Jan 2007 02:18:42 +0900
Message-ID: <20070102021842.4fd202c7.komurojun-mbn@nifty.com>
References: <20061230185043.d31d2104.komurojun-mbn@nifty.com>
	<20061230.102358.106876516.yoshfuji@linux-ipv6.org>
	<20061230205931.9e430173.komurojun-mbn@nifty.com>
	<20061230.231952.16573563.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, jgarzik@pobox.com, viro@ftp.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg504.nifty.com ([202.248.238.84]:56664 "EHLO
	userg504.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933252AbXAAITX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 03:19:23 -0500
To: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061230.231952.16573563.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> Can you reproduce it with other ftp client and/or server?

I tried the proftpd-1.3.0a-1.fc6(kernel version is 2.6.19).
The ftp stop problem does not happen.

Therefore, this problem is reproduced when
client's kernel-version is 2.6.20-rc1 or later
and server is vsftpd.
Server's kernel-version is not related with this problem.

The ftp-stop-problem happens on client's PC.

Please advise.

Best Regards
Komuro



 

