From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: Re: Generic netlink interface help
Date: 24 May 2007 10:04:08 -0000
Message-ID: <31YAj80s.1180001048.5677350.samuel@sortiz.org>
References: <20070524095654.GA21180@enneenne.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: giometti@enneenne.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:50583 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756440AbXEXKEM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 06:04:12 -0400
In-Reply-To: <20070524095654.GA21180@enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 5/24/2007, "Rodolfo Giometti" <giometti@enneenne.com> wrote:

>> You probably want to use the libnl library. The latest SVN code has
>> support for generic netlink:
>> http://people.suug.ch/~tgr/libnl/
>
>Regarding this issue I'd like to know if could be possible to avoid
>using this library... my LinuxPPS support is strictly relate with NTPD
>which doesn't use such library. It could be possible still using
>simple syscalls to access this new layer as for the old API?
Yes it's possible, even though it could be more tedious and painful.

Cheers,
Samuel.
