From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [take29 0/8] kevent: Generic event handling mechanism.
Date: Thu, 28 Dec 2006 17:01:37 +0100
Message-ID: <20061228160137.GA19301@elte.hu>
References: <3154985aa0591036@2ka.mipt.ru> <11668927001365@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754874AbWL1QFF@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <11668927001365@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Generic event handling mechanism.

i see it covers alot of event sources, but i cannot see block IO 
notifications. Am i missing something?

	Ingo
