From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Tue, 25 May 2004 10:52:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525105204.76a2b649.davem@redhat.com>
References: <20040524072657.GC27177@sgi.com>
	<20040524004045.58b3eb44.davem@redhat.com>
	<20040524080431.GD27177@sgi.com>
	<20040524100634.1349295d.davem@redhat.com>
	<20040525010434.GA31134@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040525010434.GA31134@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


So, BTW, I'm not putting in a workaround for the partial-TX-packet
ACK in tg3_tx() until we figure out why this is happening for Greg.
