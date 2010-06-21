From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Mon, 21 Jun 2010 09:57:53 +0200
Message-ID: <845400ac850a96f9f2c0dc5a878560f8@localhost>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net> <20100619221611.784f7dbc@nehalam> <20100620095019.GA32223@nuttenaction> <20100620.150928.245399526.davem@davemloft.net> <20100620215743.GA4036@nuttenaction> <AANLkTinNDMrpDUxQGjQTReuN7EyIPYNnpfO77jRFIjM7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42590 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752501Ab0FUH54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 03:57:56 -0400
In-Reply-To: <AANLkTinNDMrpDUxQGjQTReuN7EyIPYNnpfO77jRFIjM7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 21 Jun 2010 10:15:33 +0800, Changli Gao <xiaosuo@gmail.com> wrote:



> FYI: FreeBSD goes even further, and its BPF implementation exploits

> JIT in two architectures: i386 and amd64.



;-) I know. This patch is architecture neutral and provides performance

gains on all plattforms. If someone is crazy enough to implement a JIT

compiler I am fine with that too. ;-) 



HGN


