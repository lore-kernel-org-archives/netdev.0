From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch: link state detection for 8139too against 2.5.41
Date: Mon, 14 Oct 2002 13:42:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAB0215.5070507@pobox.com>
References: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com> <3DA96BCC.B2589AC0@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Take a look at how 8139cp driver does link state...  it should be an 
also exact copy of 8139cp's code.

(8139cp will eventually get GMII/TBI support, but for now this statement 
is correct)
