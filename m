From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 21:39:31 +0100
Message-ID: <20090112203931.GD23848@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122147.57731.rdenis@simphalempin.com> <20090112201435.GC23848@one.firstfloor.org> <200901122215.27842.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Valdis.Kletnieks@vt.edu,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756465AbZALUZ3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200901122215.27842.rdenis@simphalempin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What's the point of writing a parser (that could also have bugs) when the 

Sorry you lost me. What do you mean with parser here?

> kernel can do it?

And what does it have to do with the kernel?

> A normal DVD would be over 30 megabytes per seconds once decoded, just for the 
On many modern systems 30MB/s copies is nothing ... Also in this
case they tend to be cache hot, which makes them much cheaper.

Yes it would be somewhat slower, but if it avoids a couple of security
updates that would be probably worth it.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
