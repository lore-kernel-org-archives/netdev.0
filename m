From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: warning: massive change to conditional coding style in net?
Date: Mon, 30 Nov 2009 13:54:35 +0000
Message-ID: <20091130135435.3895a437@lxorguk.ukuu.org.uk>
References: <4B13A025.7000103@gmail.com>
	<20091130134414.GB7114@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: William Allen Simpson <william.allen.simpson@gmail.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:55056 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752501AbZK3Nw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 08:52:27 -0500
In-Reply-To: <20091130134414.GB7114@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Miller (with Perches) changed hundreds (thousands?) of these to
> > trailing form.  This results in a number of hilarious examples --
> > lines with both leading and trailing, lines with only &&, etc.  A
> > small sample for illustration:
> 
> Yes, it's even enough to make a grown man laugh....

IMHO for left to right languages dangly bits want to be on the right,
because that is where your eyes are when you hit the end of the previous
line, so the dangly bit is already in your line of vision and probably
even in focus.

