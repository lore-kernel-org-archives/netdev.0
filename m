From: Daniel Drake <dsd@laptop.org>
Subject: Re: [PATCH] libertas sdio: remove CMD_FUNC_INIT call
Date: Tue, 26 Feb 2013 09:33:12 -0600
Message-ID: <CAMLZHHTnRUT0pbpKR7=wVSDkOxo65tnA_JWYGtq9rejsVy2scQ@mail.gmail.com>
References: <1358493883-28433-1-git-send-email-lkundrak@v3.sk>
	<477F20668A386D41ADCC57781B1F70430D140B07DE@SC-VEXCH1.marvell.com>
	<1361249203.14137.27.camel@unicorn.kokotovo>
	<477F20668A386D41ADCC57781B1F70430D9D6CEA08@SC-VEXCH1.marvell.com>
	<1361730693.31709.1.camel@unicorn.kokotovo>
	<477F20668A386D41ADCC57781B1F70430D9D7F8FF0@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Lubomir Rintel <lkundrak@v3.sk>, Harro Haan <hrhaan@gmail.com>,
	Dan Williams <dcbw@redhat.com>,
	"libertas-dev@lists.infradead.org" <libertas-dev@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bing Zhao <bzhao@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:35948 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114Ab3BZPdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 10:33:14 -0500
In-Reply-To: <477F20668A386D41ADCC57781B1F70430D9D7F8FF0@SC-VEXCH1.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2013 at 5:21 PM, Bing Zhao <bzhao@marvell.com> wrote:
> Do you have any concern for OLPC platforms with above change? If it doesn't seem to break OLPC I will send a patch to the list.

Looks fine to me. Thanks for investigating.

Daniel
