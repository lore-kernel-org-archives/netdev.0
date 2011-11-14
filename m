From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/6] net/ethernet/atl1c: Disable ASPM on various
 chipsets
Date: Mon, 14 Nov 2011 00:34:19 -0500 (EST)
Message-ID: <20111114.003419.603215617598499123.davem@davemloft.net>
References: <1321028064-644-1-git-send-email-mjg@redhat.com>
	<1321028064-644-2-git-send-email-mjg@redhat.com>
	<20111114.003048.2051399548192848039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jcliburn@gmail.com, chris.snook@gmail.com
To: mjg@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111114.003048.2051399548192848039.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm reverting all of these.

You do all of that work to research the inf files and whatnot, then
you don't even build test the patches you submit?

Forget it, for something as potentially fragile as this stuff might
be, I simply cannot trust you if you can't even do due diligence
wrt. the build validation.
