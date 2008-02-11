From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: Engress path / congestion detection and avoidance
Date: Mon, 11 Feb 2008 10:38:39 +0000
Message-ID: <1202726319.24188.7.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: matthew.hattersley@vaioni.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:37237 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752924AbYBKKkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 05:40:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
i have few doubts related to congestion and engress path.

1) What happens when congestion hits and how it affects engress path?.
2) How the engress traffic slow down when the congestion hits?
3) what are the variables updated when the congestion hits?
4) is it good to invoke netif_stop_queue when congestion hits?

thanks
Jeba

