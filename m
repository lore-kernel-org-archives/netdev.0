From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take2] Re: Nested VLAN causes recursive locking error
Date: Thu, 10 Jan 2008 22:33:24 +0100
Message-ID: <20080110213324.GB3064@ami.dom.local>
References: <20080102234107.GA6902@ami.dom.local> <47863A4A.6070303@trash.net> <20080110210816.GA3064@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:24944 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbYAJVaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 16:30:30 -0500
Received: by fg-out-1718.google.com with SMTP id e21so840102fga.17
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 13:30:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080110210816.GA3064@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 10:08:16PM +0100, Jarek Poplawski wrote:
...
> But still some 'quirks' are possible there: removing and adding
> devices 'properly' would often require resetting of many subclasses,

...Hmm, probably they are always removed from/with the children, then no
problem! (I know, I could've checked...)

Jarek P.
