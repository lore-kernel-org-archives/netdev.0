From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v1] ax88179_178a: add reset functionality in
 reset_resume
Date: Tue, 23 Jun 2015 06:41:31 -0700 (PDT)
Message-ID: <20150623.064131.462521891937908897.davem@davemloft.net>
References: <CA+vmRF7e0Y1S_YXeHAL9u=Tp-Py_8NL3JzAVJceriFZ5Nq+LWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: vivek.bhagat89@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbbFWN3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:29:41 -0400
In-Reply-To: <CA+vmRF7e0Y1S_YXeHAL9u=Tp-Py_8NL3JzAVJceriFZ5Nq+LWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivek Bhagat <vivek.bhagat89@gmail.com>
Date: Sun, 21 Jun 2015 11:41:43 +0530

> From d178065c9e3cfa8a45ef537fae7412775339beb0 Mon Sep 17 00:00:00 2001
> From: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
> Date: Thu, 11 Jun 2015 07:23:46 -0700
> Subject: [PATCH] ax88179_178a: add reset functionality in reset_resume
> 
> Without reset functionality in reset_resume, iperf connection does not
> establish after suspend/resume however ping works at the same time.
> iperf connection fails with wrong checksum error shown by tcpdump.
> 
> reset function inside reset_resume solves above bug. We have verified
> this issue on ASIX based ST Lab, Cadyce dongle.
> 
> Signed-off-by: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
> Signed-off-by: Praveen Kumar <praveen.k09@samsung.com>

Your email client has corrupted the patch, turning TAB characters into
spaces etc.

Please fix this up and resubmit.
