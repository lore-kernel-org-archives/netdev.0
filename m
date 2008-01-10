From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: SMP code / network stack
Date: Thu, 10 Jan 2008 14:05:46 +0000
Message-ID: <1199973946.29856.27.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: matthew.hattersley@vaioni.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:2986 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754186AbYAJOHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 09:07:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

If a server has multiple processors and N number of ethernet cards, is
it possible to handle transmission by each processor separately? .In
other words, each processor will be responsible for tx of few ethernet
cards?.



Example: Server has 4 processors and 8 ethernet cards. is it possible
for each processor for transmission using 2 ethernet cards only?. So
that, at a instant , data will be send out from 8 ethernet cards.


Thanks
Jeba
