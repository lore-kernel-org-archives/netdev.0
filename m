From: Jeff Garzik <jgarzik@pobox.com>
Subject: reasons for dev_alloc_skb +16?
Date: Wed, 9 Jul 2003 11:25:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709152553.GB15293@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I knew this at one time, but have forgotten it :)

What is the reason for adding 16 to the dev_alloc_skb length?
(and skb_reserve of the same length)

	Jeff
