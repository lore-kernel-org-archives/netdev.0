From: Jes Sorensen <jes@wildopensource.com>
Subject: Re: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: 11 Jun 2003 18:21:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3y90845nu.fsf@trained-monkey.org>
References: <20030611144249.7cd63c1c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030611144249.7cd63c1c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:

Stephen> Updated acenic driver to use alloc_etherdev to hold private
Stephen> data structure.  Uses register_netdev() to get the name right
Stephen> this time ;-)

Please provide a compat macro for 2.4.18 and younger as well.

Stephen> Tested against 2.5.70 bk latest on Tigon III board.

Pretty sure it wasn't a Tigon III ;-)

Jes

PS: The name is Sorensen
