From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: Just In Time compiler for sparc
Date: Tue, 17 Apr 2012 15:42:22 -0400 (EDT)
Message-ID: <20120417.154222.453472384916762847.davem@davemloft.net>
References: <20120416.225823.1395194623649559124.davem@davemloft.net>
	<4F8DA21E.9020809@computer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: jan.ceuleers@computer.org
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <4F8DA21E.9020809@computer.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Ceuleers <jan.ceuleers@computer.org>
Date: Tue, 17 Apr 2012 19:02:22 +0200

> There is inconsistent spacing in multiple places; a few examples shown
> above.

You've never written sparc assembler before, obviously.

The extra space after the tabs is intentional, and indicates
a branch delay slot instruction.
