From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC 0/0] Introducing a generic socket offload framework
Date: Fri, 19 Aug 2011 00:03:01 +0100
Message-ID: <20110819000301.57a2626d@lxorguk.ukuu.org.uk>
References: <20110818220756.5C93E5C80B@san.sea.corp.google.com>
	<20110818235719.50365b0b@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: san@google.com (San Mehat), davem@davemloft.net, mst@redhat.com,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	digitaleric@google.com, mikew@google.com, miche@google.com,
	maccarro@google.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110818235719.50365b0b@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Q: whay happens about in process socket syscalls in another thread ?
> Thats always been the ugly in these cases either by intercepting or by
> swapping file operations on an object.

Sorry I meant "in progress" 8)
