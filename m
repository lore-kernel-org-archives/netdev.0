From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH v2] Documentation: improve line discipline method
 descriptions
Date: Wed, 30 Sep 2015 10:03:07 -0400
Message-ID: <560BEB9B.7050403@hurleysoftware.com>
References: <d43bc9f8bddbd7ce07200a8a149ae15e5eac5d6d.1436827841.git.tilman@imap.cc>
 <1436901132.2679.54.camel@tiscali.nl>
 <1349c282fb3642264c7c8c1478ce8a0dcdd93aef.1443569708.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>, Paul Bolle <pebolle@tiscali.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34529 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbbI3ODM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 10:03:12 -0400
Received: by qkfq186 with SMTP id q186so17843351qkf.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 07:03:11 -0700 (PDT)
In-Reply-To: <1349c282fb3642264c7c8c1478ce8a0dcdd93aef.1443569708.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2015 07:45 PM, Tilman Schmidt wrote:
> Mention that the ldisc open method must set tty->receive_room, and
> that many methods are optional. Add description of receive_buf2 method.

Thanks, Tilman!

Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
