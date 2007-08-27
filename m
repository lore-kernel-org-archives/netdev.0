From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Mon, 27 Aug 2007 14:50:36 +0200
Message-ID: <20070827125035.GB2854@ff.dom.local>
References: <be1b757c0708210356s633db6c0m67601b250121ea0d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Karl Meyer <adhocrocker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:58913 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751654AbXH0MtU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 08:49:20 -0400
Content-Disposition: inline
In-Reply-To: <be1b757c0708210356s633db6c0m67601b250121ea0d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21-08-2007 12:56, Karl Meyer wrote:
> fyi:
> I do not know whether it is related to the problem, but since using
> the version you told me there are these entries is my log:
> frege Hangcheck: hangcheck value past margin!
...

BTW, I don't know wheter it's related too, but I think you should try
first to get rid of these errors:

> Freeing unused kernel memory: 220k freed
> usb_id[1320]: segfault at 00000000 eip b7e25db2 esp bfd1d734 error 4
> usb_id[1329]: segfault at 00000000 eip b7e1bdb2 esp bf9c9224 error 4
> usb_id[1322]: segfault at 00000000 eip b7df3db2 esp bfcb66c4 error 4
> usb_id[1321]: segfault at 00000000 eip b7e11db2 esp bf8f4b04 error 4

Regards,
Jarek P.
