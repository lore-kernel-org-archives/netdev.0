From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Wed, 06 Apr 2011 14:21:57 -0700 (PDT)
Message-ID: <20110406.142157.68145422.davem@davemloft.net>
References: <20110406184753.GA7691@mgebm.net>
	<1302115953.8094.217.camel@nimitz>
	<20110406212041.GA2596@mgebm.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	kaber@trash.net, zbr@ioremap.net, gregkh@suse.de,
	ksrinivasan@novell.com, netdev@vger.kernel.org
To: emunson@mgebm.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110406212041.GA2596@mgebm.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric B Munson <emunson@mgebm.net>
Date: Wed, 6 Apr 2011 17:20:41 -0400

> A bisect points at commit 04f482faf50535229a5a5c8d629cf963899f857c for the
> first bad one.  Unfortunately, I have not made netconsole work yet and the
> hang is happening mostly right when X starts so I can't even see the console.
> I will keep at the netconsole and see if I can get it functioning, also I will
> try to boot this kernel in a VM and see if that helps.

Patrick, please help Eric so we can fix this bug.

Thanks.
