From: Stefan Rompf <srompf@isg.de>
Subject: Re: PATCH idea - netlink and link changes
Date: Mon, 14 Oct 2002 20:17:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAB0A4D.637F6C30@isg.de>
References: <Pine.GSO.4.30.0210120909450.23509-100000@shell.cyberus.ca> <3DAB07F9.1090802@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Hockin <thockin@sun.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> > Only one work queue please, not one per device.
> 
> What of two devices that lose link at the same time?  Say a hub or
> switch dies..

one workqueue != losing notifications. The thread is just growing quite
large, best look it up on http://marc.theaimsgroup.com/?l=linux-netdev
or some other archive.

Cheers, Stefan
