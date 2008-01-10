From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: TCP/IP stack / SMP kernel
Date: Thu, 10 Jan 2008 14:41:11 +0000
Message-ID: <1199976071.29856.32.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:3168 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754718AbYAJOmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 09:42:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
I am just wondering how TCP/IP stack runs in SMP kernel with multi
processor environment?. will TCP/IP stack be on one processor or it is
shared among the different processors?

thanks
Jeba
