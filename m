From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: inet_gifconf question
Date: Fri, 14 Sep 2012 23:09:35 +0100
Message-ID: <20120914230935.65a3769b@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:59161 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab2INWEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 18:04:41 -0400
Received: from pyramind.ukuu.org.uk (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q8EMbEPP004506
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 23:37:19 +0100
Received: from pyramind.ukuu.org.uk (localhost [127.0.0.1])
	by pyramind.ukuu.org.uk (8.14.5/8.14.5) with ESMTP id q8EM9ZCr027624
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 23:09:35 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can anyone tell me what inet_gifconf is meant to be doing with the test
of ifa->ifa_label against NULL when ifa->ifa_label is an array ?

Alan
