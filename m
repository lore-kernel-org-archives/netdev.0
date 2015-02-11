From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [GIT] Networking
Date: Wed, 11 Feb 2015 04:10:39 +0000
Message-ID: <20150211041039.GE29656@ZenIV.linux.org.uk>
References: <20150209.191601.1373941323785500419.davem@davemloft.net>
 <CA+55aFxskyQ2CkLJ8c_LDkjTY+kKSJ5N6JPjhewGYXsXcHg7nw@mail.gmail.com>
 <20150209.205209.1524645061817000265.davem@davemloft.net>
 <CA+55aFxrGRjL_d=aCZQ0sNC+pfW8nYDLb4KkUVAme5oHmjBjTw@mail.gmail.com>
 <CA+55aFwxuMcNPU-C5p2hSWuNhJW+DOi3Py0NQ--Rw9_bv3md2w@mail.gmail.com>
 <CA+55aFzJNNDi0YKXnNYF=ccYvXALRxzngiV1tARd6CdCimVRYg@mail.gmail.com>
 <CA+55aFyqFrf9cRQ7wDSDLNraR+meZ-=dwWdDThtpPtrFFqrcGw@mail.gmail.com>
 <20150211014502.GB29656@ZenIV.linux.org.uk>
 <CA+55aFwdXNYMWGGNsAzyRiZ60HE_G=CJesLShPHGxtADJd2TPQ@mail.gmail.com>
 <20150211040113.GC29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55566 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbBKEKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 23:10:42 -0500
Content-Disposition: inline
In-Reply-To: <20150211040113.GC29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2015 at 04:01:13AM +0000, Al Viro wrote:
> I hoped LTP would have them, but it doesn't ;-/  The best I'd been able to
> find had been in libkcapi, modulo bunch of
> 	let result=($result + 1)
> (in a bash script;

... which I'd been running with sh test.sh ;-/  I really need more coffee...
