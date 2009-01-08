From: "Jaswinder Singh Rajput" <jaswinderlinux@gmail.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Thu, 8 Jan 2009 11:42:42 +0530
Message-ID: <3f9a31f40901072212x41e405fh7e36f6adb927814b@mail.gmail.com>
References: <5a4c581d0901070624t6e769966t6b034b14d4732bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David Woodhouse" <dwmw2@infradead.org>
To: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:53070 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbZAHGMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 01:12:43 -0500
In-Reply-To: <5a4c581d0901070624t6e769966t6b034b14d4732bd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello alessandro,

On Wed, Jan 7, 2009 at 7:54 PM, Alessandro Suardi
<alessandro.suardi@gmail.com> wrote:
>
> Note that I don't have CONFIG_FIRMWARE_IN_KERNEL, but on
>  the other hand I didn't earlier, either... and yes, CONFIG_MODULES=y.
>

Please try with CONFIG_FIRMWARE_IN_KERNEL , is this makes some difference.

--
JSR
